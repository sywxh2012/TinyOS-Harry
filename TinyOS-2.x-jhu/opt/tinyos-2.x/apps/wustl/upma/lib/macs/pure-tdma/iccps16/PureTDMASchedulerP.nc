/*
 * "Copyright (c) 2007 Washington University in St. Louis.
 * All rights reserved.
 * @author Bo Li
 * @date $Date: 2014/10/17
 */
module PureTDMASchedulerP {
	provides {
		interface Init;
		interface SplitControl;
		interface AsyncSend as Send;
		interface AsyncReceive as Receive;
		interface CcaControl[am_id_t amId];
		interface FrameConfiguration as Frame;
	}	
	uses{			
		interface AsyncStdControl as GenericSlotter;
		interface RadioPowerControl;
		interface Slotter;
		interface SlotterControl;
		interface FrameConfiguration;
		interface AsyncSend as SubSend;
		interface AsyncSend as BeaconSend;
		interface AsyncReceive as SubReceive;
		interface AMPacket;
		interface Resend;
		interface PacketAcknowledgements;
		interface Boot;
		interface Leds;
		//interface HplMsp430GeneralIO as Pin;
		
		interface CC2420Config; //Added by Bo
		interface TossimPacketModelCCA; //Added by Bo
		interface TossimComPrintfWrite; //Added by Bo		
		interface SimMote; //Added by Bo
	}
}
implementation {
	enum { 
		SIMPLE_TDMA_SYNC = 123,
	};
	bool init;
	uint32_t slotSize;
	uint32_t bi, sd, cap;
	uint8_t coordinatorId;
	message_t *toSend; //this one will become critical later on, and cause segmentation error
	uint8_t toSendLen;
	
	//Below added by Bo
	message_t packet;
	uint32_t rounds; //Number of rounds that the simulation has been through
	uint32_t slot_counts;
	
	uint8_t get_last_hop_status(uint8_t flow_id_t, uint8_t access_type_t, uint8_t hop_count_t);
	void set_current_hop_status(uint32_t slot_t, uint8_t sender, uint8_t receiver);
	void set_send_status(uint32_t slot_at_send_done, uint8_t ack_t);
	void set_send (uint32_t slot_t);
	uint8_t get_flow_id(uint32_t slot_t, uint8_t sender, uint8_t receiver);
	uint32_t get_slot_after_rounds(uint32_t rounds);

  	//0 Slot
  	//1 Sender
  	//2 Receiver
  	//3 Channel
  	//4 Access Type:    0: dedicated,  1: shared, 2: steal, 3: ack
  	//5 Flow Type:      0: emergency, 1: regular
  	//6 Flow ID:        1, 2
  	//7 Flow root: root of the flow, i.e., sensor that launch the communcation
  	//8 Send status in sendDone: 0: no-ack, 1: acked
  	//9 Last Hop Status:
  	//10 Hop count in the flow
	
	/*debugging schedule with old topology
	uint8_t schedule[3][11]={//Test Routing, baseline.
		{1, 181, 170, 22, 0, 0, 1, 181, 0, 0, 1},
		{2, 170, 160, 22, 0, 0, 1, 181, 0, 0, 2},
		{3, 160, 161, 22, 0, 0, 1, 181, 0, 0, 3}
	};
	uint8_t schedule_len=3;
	uint32_t superframe_length = 4;
	*/
	
	/*debugging schedule with new topology, not for real.
	uint8_t schedule[2][11]={//Test Routing, baseline.
		{1, 170, 160, 22, 0, 1, 1, 170, 0, 0, 1},
		{2, 160, 161, 22, 0, 1, 1, 170, 0, 0, 2}
	};
	uint8_t schedule_len=2;
	uint32_t superframe_length = 3;	
	*/
	
	/*
	uint8_t schedule[164][11]={//PS for two plants, calculated by Chengjie's program, calibrated by Lanshun.
	//Transmission schedule for plant #1,uplink
	//flow 181, (1)
	{1, 181, 170, 22, 0, 0, 1, 181, 0, 0, 1},
	{2, 181, 170, 23, 0, 0, 1, 181, 0, 0, 1},
	{3, 170, 160, 24, 0, 0, 1, 181, 0, 0, 2},
	{3, 181, 171, 22, 1, 0, 1, 181, 0, 0, 1},
	{4, 170, 160, 22, 0, 0, 1, 181, 0, 0, 2},
	{5, 160, 161, 23, 0, 0, 1, 181, 0, 0, 3},
	{5, 170, 163, 24, 1, 0, 1, 181, 0, 0, 2},
	{6, 160, 161, 24, 0, 0, 1, 181, 0, 0, 3},
	{7, 171, 160, 22, 1, 0, 1, 181, 0, 0, 2},
	{7, 163, 161, 23, 1, 0, 1, 181, 0, 0, 3},
	{8, 160, 161, 23, 1, 0, 1, 181, 0, 0, 3},
	{9, 160, 169, 24, 1, 0, 1, 181, 0, 0, 3}
	};
	uint8_t schedule_len=154;
	uint32_t superframe_length = 53; //Real superframe length, decided by the actual number of slots per schedule
	*/
	
	/*
	//0 Slot
  	//1 Sender
  	//2 Receiver
  	//3 Channel
  	//4 Access Type:    0: dedicated,  1: shared, 2: steal, 3: ack
  	//5 Flow Type:      0: emergency, 1: regular
  	//6 Flow ID:        1, 2
  	//7 Flow root: root of the flow, i.e., sensor that launch the communcation
  	//8 Send status in sendDone: 0: no-ack, 1: acked
  	//9 Last Hop Status:
  	//10 Hop count in the flow
  	*/	
	
	
	uint8_t schedule[32][11]={//Source Routing, 16 sensor topology, 2 prime trans, retrans twice, baseline.
	//flow 170, flow sensor
	{1, 170, 160, 22, 0, 1, 1, 170, 0, 0, 1},
	{2, 170, 160, 23, 0, 1, 1, 170, 0, 0, 1},
	{2, 160, 161, 22, 0, 1, 1, 170, 0, 0, 2},
	{3, 160, 161, 23, 0, 1, 1, 170, 0, 0, 2},
	//flow 171, flow sensor
	{1, 171, 163, 23, 0, 1, 2, 171, 0, 0, 1},
	{3, 171, 163, 22, 0, 1, 2, 171, 0, 0, 1},
	{4, 163, 169, 22, 0, 1, 2, 171, 0, 0, 2},
	{5, 163, 169, 23, 0, 1, 2, 171, 0, 0, 2},
	//flow 162, flow sensor
	{4, 162, 166, 23, 0, 1, 3, 162, 0, 0, 1},
	{5, 162, 166, 22, 0, 1, 3, 162, 0, 0, 1},
	{6, 166, 161, 22, 0, 1, 3, 162, 0, 0, 2},
	{7, 166, 161, 23, 0, 1, 3, 162, 0, 0, 2},
	//flow 172, level sensor
	{6, 172, 173, 23, 0, 1, 4, 172, 0, 0, 1},
	{7, 172, 173, 22, 0, 1, 4, 172, 0, 0, 1},
	{8, 173, 169, 22, 0, 1, 4, 172, 0, 0, 2},
	{9, 173, 169, 23, 0, 1, 4, 172, 0, 0, 2},
	//flow 164, level sensor
	{8, 164, 168, 23, 0, 1, 5, 164, 0, 0, 1},
	{9, 164, 168, 22, 0, 1, 5, 164, 0, 0, 1},
	{10, 168, 161, 22, 0, 1, 5, 164, 0, 0, 2},
	{11, 168, 161, 23, 0, 1, 5, 164, 0, 0, 2},
	//flow 165, temperature senor
	{10, 165, 167, 23, 0, 1, 6, 165, 0, 0, 1},
	{11, 165, 167, 22, 0, 1, 6, 165, 0, 0, 1},
	{12, 167, 169, 22, 0, 1, 6, 165, 0, 0, 2},
	{13, 167, 169, 23, 0, 1, 6, 165, 0, 0, 2},
	
	//flow 200, actuator for pump
	{12, 161, 166, 23, 0, 1, 7, 200, 0, 0, 1},
	{13, 161, 166, 22, 0, 1, 7, 200, 0, 0, 1},
	{14, 166, 200, 22, 0, 1, 7, 200, 0, 0, 2},
	{15, 166, 200, 23, 0, 1, 7, 200, 0, 0, 2},
	//flow 201, actuator for temperature
	{14, 169, 173, 23, 0, 1, 8, 201, 0, 0, 1},
	{15, 169, 173, 22, 0, 1, 8, 201, 0, 0, 1},
	{16, 173, 201, 22, 0, 1, 8, 201, 0, 0, 2},
	{17, 173, 201, 23, 0, 1, 8, 201, 0, 0, 2}
	};
	uint8_t schedule_len=32;
	uint32_t superframe_length = 18; //5Hz at most
	
	
	/*
	uint8_t schedule[56][11]={//Graph Routing, 16 sensor topology, 2 prime + 1 backup trans, retrans twice,baseline.
	//flow 170, flow sensor
	{1, 170, 160, 22, 0, 1, 1, 170, 0, 0, 1},
	{2, 170, 160, 23, 0, 1, 1, 170, 0, 0, 1},
	{2, 160, 161, 22, 0, 1, 1, 170, 0, 0, 2},
	{3, 160, 161, 23, 0, 1, 1, 170, 0, 0, 2},
	{3, 170, 163, 22, 1, 1, 1, 170, 0, 0, 1},
	{4, 163, 161, 23, 1, 1, 1, 170, 0, 0, 2},
	{4, 160, 169, 22, 1, 1, 1, 170, 0, 0, 2},	
	//flow 171, flow sensor
	{1, 171, 163, 23, 0, 1, 2, 171, 0, 0, 1},
	{5, 171, 163, 22, 0, 1, 2, 171, 0, 0, 1},
	{5, 163, 169, 23, 0, 1, 2, 171, 0, 0, 2},
	{6, 163, 169, 22, 0, 1, 2, 171, 0, 0, 2},
	{6, 171, 160, 23, 1, 1, 2, 171, 0, 0, 1},
	{7, 160, 161, 22, 1, 1, 2, 171, 0, 0, 2},
	{7, 163, 161, 23, 1, 1, 2, 171, 0, 0, 2},	
	//flow 162, flow sensor
	{8, 162, 166, 22, 0, 1, 3, 162, 0, 0, 1},
	{9, 162, 166, 23, 0, 1, 3, 162, 0, 0, 1},
	{9, 166, 161, 22, 0, 1, 3, 162, 0, 0, 2},
	{10, 166, 161, 23, 0, 1, 3, 162, 0, 0, 2},
	{10, 162, 173, 22, 1, 1, 3, 162, 0, 0, 1},
	{11, 173, 169, 23, 1, 1, 3, 162, 0, 0, 2},
	{11, 166, 169, 22, 1, 1, 3, 162, 0, 0, 2},
	//flow 172, level sensor
	{8, 172, 173, 23, 0, 1, 4, 172, 0, 0, 1},
	{12, 172, 173, 22, 0, 1, 4, 172, 0, 0, 1},
	{12, 173, 169, 23, 0, 1, 4, 172, 0, 0, 2},
	{13, 173, 169, 22, 0, 1, 4, 172, 0, 0, 2},
	{13, 172, 166, 23, 1, 1, 4, 172, 0, 0, 1},
	{14, 166, 161, 22, 1, 1, 4, 172, 0, 0, 2},
	{14, 173, 161, 23, 1, 1, 4, 172, 0, 0, 2},
	//flow 164, level sensor
	{15, 164, 168, 22, 0, 1, 5, 164, 0, 0, 1},
	{16, 164, 168, 23, 0, 1, 5, 164, 0, 0, 1},
	{16, 168, 161, 22, 0, 1, 5, 164, 0, 0, 2},
	{17, 168, 161, 23, 0, 1, 5, 164, 0, 0, 2},
	{17, 164, 167, 22, 1, 1, 5, 164, 0, 0, 1},
	{18, 167, 169, 23, 1, 1, 5, 164, 0, 0, 2},
	{18, 168, 161, 22, 0, 1, 5, 164, 0, 0, 2},
	//flow 165, temperature senor
	{15, 165, 167, 23, 0, 1, 6, 165, 0, 0, 1},
	{19, 165, 167, 22, 0, 1, 6, 165, 0, 0, 1},
	{19, 167, 169, 23, 0, 1, 6, 165, 0, 0, 2},
	{20, 167, 169, 22, 0, 1, 6, 165, 0, 0, 2},
	{20, 165, 168, 23, 1, 1, 6, 165, 0, 0, 1},
	{21, 168, 161, 22, 1, 1, 6, 165, 0, 0, 2},
	{21, 167, 161, 23, 1, 1, 6, 165, 0, 0, 2},
	
	//flow 200, actuator for pump
	{22, 161, 166, 22, 0, 1, 7, 200, 0, 0, 1},
	{23, 161, 166, 23, 0, 1, 7, 200, 0, 0, 1},
	{23, 166, 200, 22, 0, 1, 7, 200, 0, 0, 2},
	{24, 166, 200, 23, 0, 1, 7, 200, 0, 0, 2},
	{24, 161, 173, 22, 1, 1, 7, 200, 0, 0, 1},
	{25, 173, 200, 23, 1, 1, 7, 200, 0, 0, 2},
	{25, 166, 200, 22, 1, 1, 7, 200, 0, 0, 2},
	
	//flow 201, actuator for temperature
	{22, 169, 173, 23, 0, 1, 8, 201, 0, 0, 1},
	{26, 169, 173, 22, 0, 1, 8, 201, 0, 0, 1},
	{26, 173, 201, 23, 0, 1, 8, 201, 0, 0, 2},
	{27, 173, 201, 22, 0, 1, 8, 201, 0, 0, 2},
	{27, 169, 166, 23, 1, 1, 8, 201, 0, 0, 1},
	{28, 166, 201, 22, 1, 1, 8, 201, 0, 0, 2},
	{28, 173, 201, 23, 1, 1, 8, 201, 0, 0, 2}
	};
	uint8_t schedule_len=56;
	uint32_t superframe_length = 29; //3Hz at most.
	*/
	
	/*
	uint8_t schedule[38][11]={//Asymmetric Routing, 16 sensor topology, 2 prime trans + retrans twice, new method.
	{1, 170, 160, 22, 0, 1, 1, 170, 0, 0, 1},
	{2, 170, 160, 23, 0, 1, 1, 170, 0, 0, 1},
	{2, 160, 161, 22, 0, 1, 1, 170, 0, 0, 2},
	{3, 160, 161, 22, 0, 1, 1, 170, 0, 0, 2},
	//flow 171, flow sensor
	{1, 171, 163, 23, 0, 1, 2, 171, 0, 0, 1},
	{3, 171, 163, 23, 0, 1, 2, 171, 0, 0, 1},
	{4, 163, 169, 22, 0, 1, 2, 171, 0, 0, 2},
	{5, 163, 169, 23, 0, 1, 2, 171, 0, 0, 2},
	//flow 162, flow sensor
	{4, 162, 166, 23, 0, 1, 3, 162, 0, 0, 1},
	{5, 162, 166, 22, 0, 1, 3, 162, 0, 0, 1},
	{6, 166, 161, 22, 0, 1, 3, 162, 0, 0, 2},
	{7, 166, 161, 23, 0, 1, 3, 162, 0, 0, 2},
	//flow 172, level sensor
	{6, 172, 173, 23, 0, 1, 4, 172, 0, 0, 1},
	{7, 172, 173, 22, 0, 1, 4, 172, 0, 0, 1},
	{8, 173, 169, 22, 0, 1, 4, 172, 0, 0, 2},
	{9, 173, 169, 23, 0, 1, 4, 172, 0, 0, 2},
	//flow 164, level sensor
	{8, 164, 168, 23, 0, 1, 5, 164, 0, 0, 1},
	{9, 164, 168, 22, 0, 1, 5, 164, 0, 0, 1},
	{10, 168, 161, 22, 0, 1, 5, 164, 0, 0, 2},
	{11, 168, 161, 23, 0, 1, 5, 164, 0, 0, 2},
	//flow 165, temperature senor
	{10, 165, 167, 23, 0, 1, 6, 165, 0, 0, 1},
	{11, 165, 167, 22, 0, 1, 6, 165, 0, 0, 1},
	{12, 167, 169, 22, 0, 1, 6, 165, 0, 0, 2},
	{13, 167, 169, 23, 0, 1, 6, 165, 0, 0, 2},
	
	//flow 200, actuator for pump
	{12, 161, 166, 23, 0, 1, 7, 200, 0, 0, 1},
	{13, 161, 166, 22, 0, 1, 7, 200, 0, 0, 1},
	{14, 166, 200, 22, 0, 1, 7, 200, 0, 0, 2},
	{15, 166, 200, 23, 0, 1, 7, 200, 0, 0, 2},
	{14, 161, 173, 23, 1, 1, 7, 200, 0, 0, 1},
	{15, 173, 200, 22, 1, 1, 7, 200, 0, 0, 2},
	{16, 166, 200, 23, 1, 1, 7, 200, 0, 0, 2},
	
	//flow 201, actuator for temperature
	{16, 169, 173, 22, 0, 1, 8, 201, 0, 0, 1},
	{17, 169, 173, 23, 0, 1, 8, 201, 0, 0, 1},
	{17, 173, 201, 22, 0, 1, 8, 201, 0, 0, 2},
	{18, 173, 201, 23, 0, 1, 8, 201, 0, 0, 2},
	{18, 169, 166, 22, 1, 1, 8, 201, 0, 0, 1},
	{19, 166, 201, 23, 1, 1, 8, 201, 0, 0, 2},
	{19, 173, 201, 22, 1, 1, 8, 201, 0, 0, 2}	
	};
	uint8_t schedule_len=38;
	uint32_t superframe_length = 20; //5Hz at most
	*/
	
	/*
	uint8_t schedule[50][11]={//Inversed Asymmetric Routing(iasymmetric), graph for sensing, source for actuation
	//flow 170, flow sensor
	{1, 170, 160, 22, 0, 1, 1, 170, 0, 0, 1},
	{2, 170, 160, 23, 0, 1, 1, 170, 0, 0, 1},
	{2, 160, 161, 22, 0, 1, 1, 170, 0, 0, 2},
	{3, 160, 161, 23, 0, 1, 1, 170, 0, 0, 2},
	{3, 170, 163, 22, 1, 1, 1, 170, 0, 0, 1},
	{4, 163, 161, 23, 1, 1, 1, 170, 0, 0, 2},
	{4, 160, 169, 22, 1, 1, 1, 170, 0, 0, 2},	
	//flow 171, flow sensor
	{1, 171, 163, 23, 0, 1, 2, 171, 0, 0, 1},
	{5, 171, 163, 22, 0, 1, 2, 171, 0, 0, 1},
	{5, 163, 169, 23, 0, 1, 2, 171, 0, 0, 2},
	{6, 163, 169, 22, 0, 1, 2, 171, 0, 0, 2},
	{6, 171, 160, 23, 1, 1, 2, 171, 0, 0, 1},
	{7, 160, 161, 22, 1, 1, 2, 171, 0, 0, 2},
	{7, 163, 161, 23, 1, 1, 2, 171, 0, 0, 2},	
	//flow 162, flow sensor
	{8, 162, 166, 22, 0, 1, 3, 162, 0, 0, 1},
	{9, 162, 166, 23, 0, 1, 3, 162, 0, 0, 1},
	{9, 166, 161, 22, 0, 1, 3, 162, 0, 0, 2},
	{10, 166, 161, 23, 0, 1, 3, 162, 0, 0, 2},
	{10, 162, 173, 22, 1, 1, 3, 162, 0, 0, 1},
	{11, 173, 169, 23, 1, 1, 3, 162, 0, 0, 2},
	{11, 166, 169, 22, 1, 1, 3, 162, 0, 0, 2},
	//flow 172, level sensor
	{8, 172, 173, 23, 0, 1, 4, 172, 0, 0, 1},
	{12, 172, 173, 22, 0, 1, 4, 172, 0, 0, 1},
	{12, 173, 169, 23, 0, 1, 4, 172, 0, 0, 2},
	{13, 173, 169, 22, 0, 1, 4, 172, 0, 0, 2},
	{13, 172, 166, 23, 1, 1, 4, 172, 0, 0, 1},
	{14, 166, 161, 22, 1, 1, 4, 172, 0, 0, 2},
	{14, 173, 161, 23, 1, 1, 4, 172, 0, 0, 2},
	//flow 164, level sensor
	{15, 164, 168, 22, 0, 1, 5, 164, 0, 0, 1},
	{16, 164, 168, 23, 0, 1, 5, 164, 0, 0, 1},
	{16, 168, 161, 22, 0, 1, 5, 164, 0, 0, 2},
	{17, 168, 161, 23, 0, 1, 5, 164, 0, 0, 2},
	{17, 164, 167, 22, 1, 1, 5, 164, 0, 0, 1},
	{18, 167, 169, 23, 1, 1, 5, 164, 0, 0, 2},
	{18, 168, 161, 22, 0, 1, 5, 164, 0, 0, 2},
	//flow 165, temperature senor
	{15, 165, 167, 23, 0, 1, 6, 165, 0, 0, 1},
	{19, 165, 167, 22, 0, 1, 6, 165, 0, 0, 1},
	{19, 167, 169, 23, 0, 1, 6, 165, 0, 0, 2},
	{20, 167, 169, 22, 0, 1, 6, 165, 0, 0, 2},
	{20, 165, 168, 23, 1, 1, 6, 165, 0, 0, 1},
	{21, 168, 161, 22, 1, 1, 6, 165, 0, 0, 2},
	{21, 167, 161, 23, 1, 1, 6, 165, 0, 0, 2},
	
	//below with alternative channels for the same packets, caused fewer 1-packet drops
	{22, 161, 166, 22, 0, 1, 7, 200, 0, 0, 1},
	{23, 161, 166, 23, 0, 1, 7, 200, 0, 0, 1},
	{23, 166, 200, 22, 0, 1, 7, 200, 0, 0, 2},
	{24, 166, 200, 23, 0, 1, 7, 200, 0, 0, 2},

	//{22, 169, 173, 23, 0, 1, 8, 201, 0, 0, 1},
	//{25, 169, 173, 22, 0, 1, 8, 201, 0, 0, 1},
	//{24, 173, 201, 23, 0, 1, 8, 201, 0, 0, 2},
	//{25, 173, 201, 23, 0, 1, 8, 201, 0, 0, 2}
	
	{24, 169, 173, 22, 0, 1, 8, 201, 0, 0, 1},
	{25, 169, 173, 23, 0, 1, 8, 201, 0, 0, 1},
	{25, 173, 201, 22, 0, 1, 8, 201, 0, 0, 2},
	{26, 173, 201, 23, 0, 1, 8, 201, 0, 0, 2}	
	};
	uint8_t schedule_len=50;
	uint32_t superframe_length = 27; //3Hz at most.
	*/
	
	/*
	uint8_t schedule[16][11]={//Simulated schedule for measuring link failure ratio, 16 links total in 16 slots.
	//flow 170, flow sensor
	//{1, 170, 160, 22, 0, 1, 1, 170, 0, 0, 1},
	//{2, 160, 161, 23, 0, 1, 1, 170, 0, 0, 2},
	//flow 171, flow sensor
	//{3, 171, 163, 23, 0, 1, 2, 171, 0, 0, 1},
	//{4, 163, 169, 22, 0, 1, 2, 171, 0, 0, 2},
	//flow 162, flow sensor
	//{5, 162, 166, 23, 0, 1, 3, 162, 0, 0, 1},
	//{6, 166, 161, 22, 0, 1, 3, 162, 0, 0, 2},
	//flow 172, level sensor
	{7, 172, 173, 23, 0, 1, 4, 172, 0, 0, 1},
	{8, 173, 169, 22, 0, 1, 4, 172, 0, 0, 2},
	//flow 164, level sensor
	//{9, 164, 168, 23, 0, 1, 5, 164, 0, 0, 1},
	//{10, 168, 161, 22, 0, 1, 5, 164, 0, 0, 2},
	//flow 165, temperature senor
	{11, 165, 167, 23, 0, 1, 6, 165, 0, 0, 1},
	{12, 167, 169, 22, 0, 1, 6, 165, 0, 0, 2},
	//flow 200, actuator for pump
	{13, 161, 166, 23, 0, 1, 7, 200, 0, 0, 1},
	{14, 166, 200, 22, 0, 1, 7, 200, 0, 0, 2},
	//flow 201, actuator for temperature
	{15, 169, 173, 23, 0, 1, 8, 201, 0, 0, 1},
	{16, 173, 201, 22, 0, 1, 8, 201, 0, 0, 2},
	};
	uint8_t schedule_len=16;
	uint32_t superframe_length = 18;
	*/
	//Above schedule could be problematic because of the array size, and other hidden reason
	//We should re do a more standard schedule and redo the link failure statistics
	
	/*
	uint8_t schedule[8][11]={//Simulated schedule for measuring link failure ratio, 16 links total in 16 slots.
	//flow 172, level sensor
	{1, 172, 173, 23, 0, 1, 4, 172, 0, 0, 1},
	{2, 173, 169, 22, 0, 1, 4, 172, 0, 0, 2},
	//flow 165, temperature senor
	{3, 165, 167, 23, 0, 1, 6, 165, 0, 0, 1},
	{4, 167, 169, 22, 0, 1, 6, 165, 0, 0, 2},
	//flow 200, actuator for pump
	{5, 161, 166, 23, 0, 1, 7, 200, 0, 0, 1},
	{6, 166, 200, 22, 0, 1, 7, 200, 0, 0, 2},
	//flow 201, actuator for temperature
	{7, 169, 173, 23, 0, 1, 8, 201, 0, 0, 1},
	{8, 173, 201, 22, 0, 1, 8, 201, 0, 0, 2},
	};
	uint8_t schedule_len = 8;
	uint32_t superframe_length = 18;
	*/
	
	bool sync;
	bool requestStop;
	uint32_t sync_count=0;

event void Boot.booted(){
}

command error_t Init.init() {		
	slotSize = 10 * 32;     //10ms
	
	//bi = 16; //# of slots from original TDMA code
	//sd = 11; //last active slot from original TDMA code
		
	bi = 9000; //source routing, 18x500, this can be used for link failure measurement too
	sd = 9000; 
	slot_counts = 9000;

	//bi = 14500; //graph routing
	//sd = 14500;
	//slot_counts = 14500;

	//bi = 10000; //asymmetric routing
	//sd = 10000;
	//slot_counts = 10000;
	
	//bi = 13500; //Inversed asymmetric routing
	//sd = 13500;
	//slot_counts = 13500;
	
	/*longer simulation for control trace input*/
	
	//bi = 720000; //source routing, 18x40000
	//sd = 720000; 
	//slot_counts = 720000;

	//bi = 1160000; //graph routing, 29*40000
	//sd = 1160000;
	//slot_counts = 1160000;

	//bi = 800000; //asymmetric routing, 20*40000
	//sd = 800000;
	//slot_counts = 800000;
	
	//bi = 1080000; //Inversed asymmetric routing, 27*40000
	//sd = 1080000;
	//slot_counts = 1080000;
	
		
	/*The bottom line is that we want the network to be synchronized once and keep running
	while recycling through 0- superframe_length, because Simulink cannot stop in the middle*/

	cap = 0; // what is this used for? is this yet another superframe length?
	coordinatorId = 0;
	init = FALSE;
	toSend = NULL;
	toSendLen = 0;
	sync = FALSE;
	requestStop = FALSE;
	rounds = 0;
	return SUCCESS;		
}
	
 	command error_t SplitControl.start() {
 		error_t err;
 		if (init == FALSE) {
 			call FrameConfiguration.setSlotLength(slotSize);
 			call FrameConfiguration.setFrameLength(bi+1);
 			//call FrameConfiguration.setFrameLength(1000);
 		}
 		err = call RadioPowerControl.start();
 		return err;
 	}
 	
 	command error_t SplitControl.stop() {
 		printf("This is sensor: %u and the SplitControl.stop has been reached\n", TOS_NODE_ID);
 		requestStop = TRUE;
 		call GenericSlotter.stop();
 		call RadioPowerControl.stop();
 		return SUCCESS;
 	}
 	
 	event void RadioPowerControl.startDone(error_t error) {
 	 	int i;
 		if (coordinatorId == TOS_NODE_ID) { 		
 			if (init == FALSE) { 
 				signal SplitControl.startDone(error); //start sensor 0
 				call GenericSlotter.start(); //start slot counter
 				call SlotterControl.synchronize(0); //synchronize the rest sensors in the network
 				init = TRUE; 				
 			}
 		} else {
 			if (init == FALSE) {
 				signal SplitControl.startDone(error); //start all non-zero sensors
 				init = TRUE; //initialization done
 			}
 		} 		
	}
	
 	event void RadioPowerControl.stopDone(error_t error)  {
		if (requestStop)  {
			printf("This is sensor: %u and the RadioPowerControl.stopDone has been reached\n", TOS_NODE_ID);
			requestStop = FALSE;
			signal SplitControl.stopDone(error);
		}
	}
 	
 	/****************************
 	 *   Implements the schedule
 	 */ 	
 	async event void Slotter.slot(uint32_t slot) { 		
 		message_t *tmpToSend;
 		uint8_t tmpToSendLen;
 		uint8_t i;
 		
 		if ((slot) == 0 ) {
 			if (coordinatorId == TOS_NODE_ID) {
 				call BeaconSend.send(NULL, 0);
 				//printf("This is sensor: %u and I have done network synchronization at the slot: %u\n", TOS_NODE_ID, slot % superframe_length);
 				printf("This is sensor: %u and I have done network synchronization at the slot: %u\n", TOS_NODE_ID, slot);
 			};
 			return;	
 		}
 		
 		if (call SlotterControl.getSlot() % superframe_length == 1){
   			rounds = rounds + 1; // we use this to track the number of rounds (superframes) that has been run since the start of the simulation
 			//printf("SENSOR:%u, changing rounds to ROUNDS: %u. \n", TOS_NODE_ID, rounds);
 		}
 		
  		if ((slot % superframe_length) == 0 ) {
 			if (TOS_NODE_ID == 161 && slot == slot_counts){
 				//printf("SENSOR: %u, slot normalization on physical SLOT: %u.\n", TOS_NODE_ID, slot);
 				printf("SENSOR: %u, slot normalization on physical SLOT: %u.\n", TOS_NODE_ID, slot);
 			}
 			for (i=0; i<schedule_len; i++){
  				schedule[i][8]=0; //re-enable transmission by set the flag bit to 0, implying this transmission is unfinished and to be conducted.
  			}
 		} 		  	
 		
 		if (slot >= sd+1) {
 		/*	//sleep 			
 			if (slot == sd+1) {
 				call RadioPowerControl.stop();
 				//call Pin.clr();
 			}
 			//wakeup
 			if (slot == bi) {
 				call RadioPowerControl.start();
 				//call Pin.set();
 				//call Leds.led0On();
 			} */
 			return;
 		}
 		if (slot < cap) { 
 		} else {
 			set_send (slot % superframe_length); //heart beat control
 			//if(TOS_NODE_ID==181){
 				//printf("Slot checking, this is Sensor: %u and current time slot is: %u\n", TOS_NODE_ID, slot);
 			//}	
 		}
 	}

 	async command error_t Send.send(message_t * msg, uint8_t len) {
 		atomic {
 			if (toSend == NULL) {
 				toSend = msg;
 				toSendLen = len;
 				return SUCCESS;
 			}
 		}		
 		return FAIL;
 	}

	async event void SubSend.sendDone(message_t * msg, error_t error) {
		uint32_t slot_at_send_done;
		uint8_t ack_at_send_done;	
		slot_at_send_done = call SlotterControl.getSlot() % superframe_length;
		ack_at_send_done = call PacketAcknowledgements.wasAcked(msg)?1:0;	
		
		//iccps16, generate send/receive status for actions that really happened, such that we know energy consumption for both sender/rcver
		printf("%u, %u, %u, %u, %u, %u\n", TOS_NODE_ID, call AMPacket.destination(msg), call SlotterControl.getSlot(), call CC2420Config.getChannel(), call PacketAcknowledgements.wasAcked(msg)?1:0, rounds);
				
		//link failure statistics
		if(ack_at_send_done==0){
			//printf("%u, %u, %u, %u, %u, %u\n", 1, TOS_NODE_ID, call AMPacket.destination(msg), call SlotterControl.getSlot(), call CC2420Config.getChannel(), 0);
		}
		set_send_status(slot_at_send_done, ack_at_send_done);		
		//printf("Slot: %u, SENSOR:%u, Sent to: %u with %s @ %s\n", call SlotterControl.getSlot(), TOS_NODE_ID, call AMPacket.destination(msg), call PacketAcknowledgements.wasAcked(msg)? "ACK":"NOACK", sim_time_string());
		if (msg == &packet) {
			if (call AMPacket.type(msg) != SIMPLE_TDMA_SYNC) { 
				signal Send.sendDone(msg, error);
			} else {
			}
		}		
	}
	
 	//provide the send interface
 	async command error_t Send.cancel(message_t *msg) { 
  		atomic {
 			if (toSend == NULL) return SUCCESS;
 			atomic toSend = NULL;
 		}
 		return call SubSend.cancel(msg);
 	}

	/**
	 * Receive
	 */
	async event void SubReceive.receive(message_t *msg, void *payload, uint8_t len) {
		am_addr_t src = call AMPacket.source(msg);
		uint8_t i;
		uint8_t flow_id_rcv;
		char * printfResults;
		set_current_hop_status(call SlotterControl.getSlot() % superframe_length, src, TOS_NODE_ID);
		flow_id_rcv=get_flow_id(call SlotterControl.getSlot() % superframe_length, src, TOS_NODE_ID);
		
		//iccps16, print reception status to calculate link failure ratio
		//printf("%u %u %u %u %u %u\n", flow_id_rcv, call SlotterControl.getSlot() % superframe_length, src, TOS_NODE_ID, call CC2420Config.getChannel(), rounds);
		
		if(TOS_NODE_ID==161 || TOS_NODE_ID==169 || TOS_NODE_ID == 200 || TOS_NODE_ID == 201){
			//printf("FLOW:%u RECEIVED: %u->%u, SLOT:%u (time: %s), channel: %u\n", flow_id_rcv, src, TOS_NODE_ID, call SlotterControl.getSlot(), sim_time_string(), call CC2420Config.getChannel());
			//Flow ID, Delay(Slot when received), sender, receiver, channel, physical time.
			
			//iccps16, this printf generates the traces for end-to-end receiving status, fail or succeed a flow
			//printf("%u %u %u %u %u %u\n", flow_id_rcv, call SlotterControl.getSlot() % superframe_length, src, TOS_NODE_ID, call CC2420Config.getChannel(), rounds);
			
			//printf("%u %u %u %u %u\n", flow_id_rcv, call SlotterControl.getSlot() % superframe_length, src, TOS_NODE_ID, call CC2420Config.getChannel());
			//printf("%u, SLOT: %u, %u, %u, %u\n", flow_id_rcv, call SlotterControl.getSlot() % superframe_length, src, TOS_NODE_ID, call CC2420Config.getChannel());
			//call TossimComPrintfWrite.printfWrite(flow_id_rcv, call SlotterControl.getSlot() % superframe_length, src, TOS_NODE_ID, call CC2420Config.getChannel()); //writing results to file, differentiated by file name 
			//printf("This is Sensor: %u, and we have just called TossimComPrintfWrite.printfWrite, at Slot: %u\n", TOS_NODE_ID, call SlotterControl.getSlot() % superframe_length);	
		
			//below is the tcp approach based on a global variable on each sensor, tcp_msg, defined in SimMoteP.nc added by Bo			
			//call SimMote.setTcpMsg(flow_id_rcv, call SlotterControl.getSlot() % superframe_length, src, TOS_NODE_ID, call CC2420Config.getChannel());		
		
		}/*else if(TOS_NODE_ID == 200 || TOS_NODE_ID == 201){
			//printf("FLOW:%u RECEIVED: %u->%u, SLOT:%u (time: %s), channel: %u\n", flow_id_rcv, src, TOS_NODE_ID, call SlotterControl.getSlot(), sim_time_string(), call CC2420Config.getChannel());
			//Flow ID, Delay(Slot when received), sender, receiver, channel, physical time.
			
			//below is the file appraoch
			printf("%u, SLOT: %u, %u, %u, %u\n", flow_id_rcv, call SlotterControl.getSlot() % superframe_length, src, TOS_NODE_ID, call CC2420Config.getChannel());
			//call TossimComPrintfWrite.printfWrite(flow_id_rcv, call SlotterControl.getSlot() % superframe_length, src, TOS_NODE_ID, call CC2420Config.getChannel()); //writing results to file, differentiated by file name
			//printf("This is Sensor: %u, and we have just called TossimComPrintfWrite.printfWrite, at Slot: %u\n", TOS_NODE_ID, call SlotterControl.getSlot() % superframe_length);
			
			//below is the tcp approach based on a global variable on each sensor, tcp_msg, defined in SimMoteP.nc added by Bo			
			//call SimMote.setTcpMsg(flow_id_rcv, call SlotterControl.getSlot() % superframe_length, src, TOS_NODE_ID, call CC2420Config.getChannel());
		}*/
		//printf("RECEIVE: %u->%u, SLOT:%u (time: %s), channel: %u\n", src,TOS_NODE_ID, call SlotterControl.getSlot(), sim_time_string(), call CC2420Config.getChannel());
		signal Receive.receive(msg, payload, len);
	}	
	
	
	
	/** 
	 * Frame configuration
	 * These interfaces are provided for external use, which is misleading as these interfaces are already implemented in GenericClotterC and P
	 */
  	command void Frame.setSlotLength(uint32_t slotTimeBms) {
		atomic slotSize = slotTimeBms;
		call FrameConfiguration.setSlotLength(slotSize);
 	}
 	command void Frame.setFrameLength(uint32_t numSlots) {
 		/*atomic bi = numSlots;
		call FrameConfiguration.setFrameLength(bi+1);
		*/
 	}
 	command uint32_t Frame.getSlotLength() {
 		return slotSize;
 	}
 	command uint32_t Frame.getFrameLength() {
 		return bi+1;
 	}	
 	
	/**
	 * MISC functions
	 */
	async command void *Send.getPayload(message_t * msg, uint8_t len) {
		return call SubSend.getPayload(msg, len); 
	}
	
	async command uint8_t Send.maxPayloadLength() {
		return call SubSend.maxPayloadLength();
	}
	
	//provide the receive interface
	command void Receive.updateBuffer(message_t * msg) { return call SubReceive.updateBuffer(msg); }
	
	default async event uint16_t CcaControl.getInitialBackoff[am_id_t id](message_t * msg, uint16_t defaultbackoff) {
		return 0;
	}
	
	default async event uint16_t CcaControl.getCongestionBackoff[am_id_t id](message_t * msg, uint16_t defaultBackoff) {
		return 0;
	}
        
	default async event bool CcaControl.getCca[am_id_t id](message_t * msg, bool defaultCca) {
		return FALSE;
	}
	
    event void CC2420Config.syncDone(error_t error){}
    async event void BeaconSend.sendDone(message_t * msg, error_t error){}
    
    uint8_t get_last_hop_status(uint8_t flow_id_t, uint8_t access_type_t, uint8_t hop_count_t){
    	uint8_t last_hop_status=0;
    	uint8_t i;
    	for (i=0; i<schedule_len; i++){
    		if(schedule[i][0] <= call SlotterControl.getSlot() % superframe_length){
    			if (schedule[i][6]==flow_id_t){//check flow ID
					if(schedule[i][10] == (hop_count_t-1)){//check the previous hop-count
						if(schedule[i][9]==1){
							last_hop_status = schedule[i][9];
							//printf("Sensor:%u, GETTING RECEIVE, Slot:%u, %u, %u, %u, %u, %u , %u, %u, %u, %u, %u.\n", TOS_NODE_ID, schedule[i][0], schedule[i][1], schedule[i][2], schedule[i][3], schedule[i][4], schedule[i][5], schedule[i][6], schedule[i][7], schedule[i][8], schedule[i][9], schedule[i][10]);
						}						
					}
    			}
    		}
		}
		return last_hop_status;
    }//end of get_last_hop_status
    
    void set_current_hop_status(uint32_t slot_t, uint8_t sender, uint8_t receiver){
    	uint8_t i;
    	for (i=0; i<schedule_len; i++){
    		if(schedule[i][0]==slot_t){// check send-receive pairs 1 slot before/after current slot
    			if(schedule[i][1] == sender){//check sender
					if(schedule[i][2] == receiver){//check receiver
						schedule[i][9]=1;
						//printf("Sensor:%u, SETTING RECEIVE, Slot:%u, %u, %u, %u, %u, %u , %u, %u, %u, [9]%u, %u.\n", TOS_NODE_ID, schedule[i][0], schedule[i][1], schedule[i][2], schedule[i][3], schedule[i][4], schedule[i][5], schedule[i][6], schedule[i][7], schedule[i][8], schedule[i][9], schedule[i][10]);
					}
				}
    		}
		}
    }// end of set_current_hop_status
    
    uint8_t get_flow_id(uint32_t slot_t, uint8_t sender, uint8_t receiver){
    	uint8_t i;
    	uint8_t flow_id_t=0;
    	for (i=0; i<schedule_len; i++){
    		if(schedule[i][0]==slot_t){// check send-receive pairs 1 slot before/after current slot
    			if(schedule[i][1] == sender){//check sender
					if(schedule[i][2] == receiver){//check receiver
						flow_id_t=schedule[i][6];
					}
				}
    		}
		}
		return flow_id_t;
    } // end of get_flow_id
      
	void set_send_status(uint32_t slot_at_send_done, uint8_t ack_at_send_done){
   		uint8_t k, i;
   		uint8_t flow_id_at_send_done;
   		uint8_t root_id_at_send_done;
   		uint8_t access_type_at_send_done;
   		
		for (k=0; k<schedule_len; k++){
			if(schedule[k][0] == slot_at_send_done && schedule[k][1] ==TOS_NODE_ID){
				flow_id_at_send_done=schedule[k][6];
				root_id_at_send_done=schedule[k][7];
				access_type_at_send_done=schedule[k][4]; // get the right line of the schedule
			}
		}
	
		//printf("SENSOR:%u, Slot:%u, i:%u\n", TOS_NODE_ID, slot_at_send_done, i);
		if(access_type_at_send_done == 0 || access_type_at_send_done == 2){ // if this is a dedicated slot
		//if(access_type_at_send_done == 0){ // if this is a dedicated slot
			if (ack_at_send_done==1){
				for (i=0; i<schedule_len; i++){
					if (schedule[i][6]==flow_id_at_send_done){ //check flow id
						if(schedule[i][7] == root_id_at_send_done){//check root
							schedule[i][8]=1;
							//printf("***DEDICATED: SENSOR: %u, KILLING POTENTIAL SEND: Slot:%u, %u, %u, %u, %u, %u , %u, %u, %u.\n", TOS_NODE_ID, schedule[i][0], schedule[i][1], schedule[i][2], schedule[i][3], schedule[i][4], schedule[i][5], schedule[i][6], schedule[i][7], schedule[i][8]);
						}
					}
				}
			}
			else{
			}
		}else if(access_type_at_send_done==1){//if this is a shared slot
			//printf("SHARED: SENSOR: %u, DISABLING: Slot:%u, %u, %u, %u, %u, %u , %u, %u, %u.\n", TOS_NODE_ID, schedule[i][0], schedule[i][1], schedule[i][2], schedule[i][3], schedule[i][4], schedule[i][5], schedule[i][6], schedule[i][7], schedule[i][8]);
			if (ack_at_send_done==1){
				//printf("SHARED111: SENSOR: %u, KILLING POTENTIAL SEND: Slot:%u, %u, %u, %u, %u, %u , %u, %u, %u.\n", TOS_NODE_ID, schedule[i][0], schedule[i][1], schedule[i][2], schedule[i][3], schedule[i][4], schedule[i][5], schedule[i][6], schedule[i][7], schedule[i][8]);
			}
			else{
				for (i=0; i<schedule_len; i++){
					if (schedule[i][6]==flow_id_at_send_done){ //check flow id
							schedule[i][8]=1;
					}
				}
				//printf("SHARED222: SENSOR: %u, KILLING POTENTIAL SEND: Slot:%u, %u, %u, %u, %u, %u , %u, %u, %u.\n", TOS_NODE_ID, schedule[i][0], schedule[i][1], schedule[i][2], schedule[i][3], schedule[i][4], schedule[i][5], schedule[i][6], schedule[i][7], schedule[i][8]);
			}
		}
   }// end of set_send_status
   
   	void set_send (uint32_t slot_t){
		uint8_t i;
		uint32_t slot_norm = slot_t; //Here slot_norm is the real time slot normalized by superframe length
		for (i=0; i<schedule_len; i++){	  			
  			if (slot_norm == schedule[i][0]){//check slot  			
  				if(TOS_NODE_ID == schedule[i][1] || TOS_NODE_ID == schedule[i][2]){//check sender & receiver id
  					if(schedule[i][10]>1){ //check if this is on a multi-hop path
  						if(TOS_NODE_ID == schedule[i][1] && schedule[i][8]==0){// problem HERE! why 8? No. 8 in the schedule is Send status in sendDone
  			  				if (get_last_hop_status(schedule[i][6], schedule[i][4], schedule[i][10])){// if above so, check delivery status of last hop
								call CC2420Config.setChannel(schedule[i][3]);
  								call CC2420Config.sync();
  								call AMPacket.setDestination(&packet, schedule[i][2]);
  								call PacketAcknowledgements.requestAck(&packet);
  								
  								call TossimPacketModelCCA.set_cca(schedule[i][4]); //schedule[i][4]: 0, TDMA; 1, CSMA contending; 2, CSMA steal;	
	  							call SubSend.send(&packet, sizeof(TestNetworkMsg));
	  							
	  							//sequence, sender, receiver, access type, slot, channel
	  							//printf("Node: %u, Link Failure detection.\n");
	  							//printf("%u, %u, %u, %u, %u, %u, %u, %u\n", 0, TOS_NODE_ID, schedule[i][2], schedule[i][4], slot_norm, call CC2420Config.getChannel(), schedule[i][5], schedule[i][6]);
	  							
	  							// print out multihop send status
	  							//printf("SENDER, HOP >1: %u->%u, Flow:%u, AccessType:%u, slot: %u, channel: %u, time: %s\n", TOS_NODE_ID, call AMPacket.destination(&packet), schedule[i][6], schedule[i][4], slot_norm, schedule[i][3], sim_time_string());  				  			
  			  				}// end check last hop
  			  			}// end sender check
  			  			if(TOS_NODE_ID == schedule[i][2] && schedule[i][8]==0){
 	 			  				//printf("RECEIVER, HOP >1: %u, slot: %u, channel: %u, time: %s\n", TOS_NODE_ID, slot_norm, schedule[i][3], sim_time_string());
  			  					call CC2420Config.setChannel(schedule[i][3]);
  								call CC2420Config.sync();
  						}//end receiver check
  					}else{
  						if(TOS_NODE_ID == schedule[i][1] && schedule[i][8]==0){
  			  				call CC2420Config.setChannel(schedule[i][3]);
  							call CC2420Config.sync();
  							call AMPacket.setDestination(&packet, schedule[i][2]);
  							call PacketAcknowledgements.requestAck(&packet);
	  						
	  						call TossimPacketModelCCA.set_cca(schedule[i][4]); //schedule[i][4]: 0, TDMA; 1, CSMA contending; 2, CSMA steal;	
	  						call SubSend.send(&packet, sizeof(TestNetworkMsg));
	  						
	  						//printf("Node: %u, Link Failure detection.\n");
	  						//printf("%u, %u, %u, %u, %u, %u, %u, %u\n", 0, TOS_NODE_ID, schedule[i][2], schedule[i][4], slot_norm, call CC2420Config.getChannel(), schedule[i][5], schedule[i][6]);

	  						// print out multihop send status
	  						//printf("SENDER, HOP =1: %u->%u, Flow:%u, AccessType:%u, slot: %u, channel: %u, time: %s\n", TOS_NODE_ID, call AMPacket.destination(&packet), schedule[i][6], schedule[i][4], slot_norm, schedule[i][3], sim_time_string());  				  			
	  					}
  						if(TOS_NODE_ID == schedule[i][2] && schedule[i][8]==0){
	  						//printf("RECEIVER, HOP =1: %u, slot: %u, channel: %u, time: %s\n", TOS_NODE_ID, slot_norm, schedule[i][3], sim_time_string());
  			  				call CC2420Config.setChannel(schedule[i][3]);
  							call CC2420Config.sync();
  						}
  					}//end else
  				}//end slot check
  			}//end sender || receiver check
  		}//end for
   	}//end set_send
   	
   	uint32_t get_slot_after_rounds(uint32_t rounds){
   		uint32_t slot_temp;
   		slot_temp  = call SlotterControl.getSlot() - rounds*superframe_length;
   		printf("SENSOR:%u called at SLOT: %u, with ROUNDS: %u, and slot_temp: %u\n", TOS_NODE_ID, call SlotterControl.getSlot(), rounds, slot_temp);
   		return slot_temp;
   	}
}