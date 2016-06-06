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
		
		//Added by Bo
		interface CC2420Config;
		
		//Added by Bo
		interface TossimPacketModelCCA;
		interface TossimComPrintfWrite;
		
		interface SimMote;
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
	
	uint8_t get_last_hop_status(uint8_t flow_id_t, uint8_t access_type_t, uint8_t hop_count_t);
	void set_current_hop_status(uint32_t slot_t, uint8_t sender, uint8_t receiver);
	void set_send_status(uint32_t slot_at_send_done, uint8_t ack_t);
	void set_send (uint32_t slot_t);
	uint8_t get_flow_id(uint32_t slot_t, uint8_t sender, uint8_t receiver);
  	
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

//int printfWr(int flow, int slot, int source, int node_id, int channel);

uint8_t schedule[164][11]={//PS for two plants, calculated by Chengjie's program,modified by Lanshun.
//Transmission schedule for plant #1,uplink

//flow 181
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
{9, 160, 169, 24, 1, 0, 1, 181, 0, 0, 3},

//flow 153
{1, 153, 171, 23, 0, 0, 2, 153, 0, 0, 1},
{2, 153, 171, 24, 0, 0, 2, 153, 0, 0, 1},
{4, 171, 163, 23, 0, 0, 2, 153, 0, 0, 2},
{6, 171, 163, 22, 0, 0, 2, 153, 0, 0, 2},
{6, 153, 170, 23, 1, 0, 2, 153, 0, 0, 1},
{7, 170, 160, 22, 1, 0, 2, 153, 0, 0, 2},
{8, 163, 169, 24, 0, 0, 2, 153, 0, 0, 3},
{10, 163, 169, 22, 0, 0, 2, 153, 0, 0, 3},
{10, 160, 161, 23, 1, 0, 2, 153, 0, 0, 3},
{11, 171, 160, 23, 1, 0, 2, 153, 0, 0, 2},
{11, 163, 161, 24, 1, 0, 2, 153, 0, 0, 3},
{12, 160, 161, 24, 1, 0, 2, 153, 0, 0, 3},

//flow 152
{1, 152, 162, 24, 0, 0, 3, 152, 0, 0, 1},
{2, 152, 162, 22, 0, 0, 3, 152, 0, 0, 1},
{3, 152, 171, 22, 1, 0, 3, 152, 0, 0, 1},
{3, 162, 173, 23, 0, 0, 3, 152, 0, 0, 2},
{4, 162, 173, 24, 0, 0, 3, 152, 0, 0, 2},
{5, 171, 163, 24, 1, 0, 3, 152, 0, 0, 2},
{5, 162, 163, 24, 1, 0, 3, 152, 0, 0, 2},
{5, 173, 169, 22, 0, 0, 3, 152, 0, 0, 3},
{7, 173, 169, 24, 0, 0, 3, 152, 0, 0, 3},
{8, 173, 161, 23, 1, 0, 3, 152, 0, 0, 3},
{9, 163, 169, 24, 1, 0, 3, 152, 0, 0, 3},
{9, 163, 161, 22, 1, 0, 3, 152, 0, 0, 3},

//flow 155
{8, 155, 172, 22, 0, 0, 4, 155, 0, 0, 1},
{9, 155, 172, 23, 0, 0, 4, 155, 0, 0, 1},
{10, 172, 173, 24, 0, 0, 4, 155, 0, 0, 2},
{11, 172, 173, 22, 0, 0, 4, 155, 0, 0, 2},
{12, 173, 169, 22, 0, 0, 4, 155, 0, 0, 3},
{12, 155, 162, 23, 1, 0, 4, 155, 0, 0, 1},
{13, 173, 169, 22, 0, 0, 4, 155, 0, 0, 3},
{13, 172, 163, 23, 1, 0, 4, 155, 0, 0, 2},
{14, 162, 173, 23, 1, 0, 4, 155, 0, 0, 2},
{14, 163, 161, 24, 1, 0, 4, 155, 0, 0, 3},
{14, 173, 161, 24, 1, 0, 4, 155, 0, 0, 3},
{15, 173, 169, 24, 1, 0, 4, 155, 0, 0, 3},

//flow 154
{14, 154, 172, 22, 0, 1, 5, 154, 0, 0, 1},
{15, 154, 172, 22, 0, 1, 5, 154, 0, 0, 1},
{16, 172, 173, 22, 0, 1, 5, 154, 0, 0, 2},
{16, 154, 162, 23, 1, 1, 5, 154, 0, 0, 1},
{17, 172, 173, 23, 0, 1, 5, 154, 0, 0, 2},
{17, 162, 163, 24, 1, 1, 5, 154, 0, 0, 2},
{18, 173, 169, 24, 0, 1, 5, 154, 0, 0, 3},
{18, 163, 161, 22, 1, 1, 5, 154, 0, 0, 3},
{19, 173, 169, 22, 0, 1, 5, 154, 0, 0, 3},
{19, 172, 163, 23, 1, 1, 5, 154, 0, 0, 2},
{20, 163, 161, 23, 1, 1, 5, 154, 0, 0, 3},
{20, 173, 161, 23, 1, 1, 5, 154, 0, 0, 3},

//Transmission schedule for plant #2,uplink
//flow 182
{13, 182, 170, 24, 0, 0, 6, 182, 0, 0, 1},
{15, 182, 170, 23, 0, 0, 6, 182, 0, 0, 1},
{16, 170, 160, 24, 0, 0, 6, 182, 0, 0, 2},
{17, 170, 160, 22, 0, 0, 6, 182, 0, 0, 2},
{18, 182, 171, 23, 1, 0, 6, 182, 0, 0, 1},
{19, 170, 163, 23, 1, 0, 6, 182, 0, 0, 2},
{19, 160, 161, 24, 0, 0, 6, 182, 0, 0, 3},
{20, 171, 160, 24, 1, 0, 6, 182, 0, 0, 2},
{21, 160, 161, 24, 0, 0, 6, 182, 0, 0, 3},
{22, 160, 161, 22, 1, 0, 6, 182, 0, 0, 3},
{22, 163, 161, 22, 1, 0, 6, 182, 0, 0, 3},
{23, 160, 169, 23, 1, 0, 6, 182, 0, 0, 3},

//flow 253
{21, 253, 171, 22, 0, 0, 7, 253, 0, 0, 1},
{22, 253, 171, 23, 0, 0, 7, 253, 0, 0, 1},
{23, 171, 163, 24, 0, 0, 7, 253, 0, 0, 2},
{23, 253, 170, 22, 1, 0, 7, 253, 0, 0, 1},
{24, 171, 163, 24, 0, 0, 7, 253, 0, 0, 2},
{24, 170, 160, 22, 1, 0, 7, 253, 0, 0, 2},
{25, 163, 169, 22, 0, 0, 7, 253, 0, 0, 3},
{25, 160, 161, 23, 1, 0, 7, 253, 0, 0, 3},
{26, 163, 169, 23, 0, 0, 7, 253, 0, 0, 3},
{26, 171, 160, 24, 1, 0, 7, 253, 0, 0, 2},
{27, 160, 161, 24, 1, 0, 7, 253, 0, 0, 3},
{27, 163, 161, 24, 1, 0, 7, 253, 0, 0, 3},

//flow 252
{20, 252, 162, 22, 0, 0, 8, 252, 0, 0, 1},
{21, 252, 162, 23, 0, 0, 8, 252, 0, 0, 1},
{22, 162, 173, 24, 0, 0, 8, 252, 0, 0, 2},
{24, 162, 173, 23, 0, 0, 8, 252, 0, 0, 2},
{25, 252, 171, 24, 1, 0, 8, 252, 0, 0, 1},
{27, 173, 169, 22, 0, 0, 8, 252, 0, 0, 3},
{28, 173, 169, 22, 0, 0, 8, 252, 0, 0, 3},
{28, 171, 163, 23, 1, 0, 8, 252, 0, 0, 2},
{28, 162, 163, 23, 1, 0, 8, 252, 0, 0, 2},
{29, 163, 161, 23, 1, 0, 8, 252, 0, 0, 3},
{29, 173, 161, 23, 1, 0, 8, 252, 0, 0, 3},
{30, 163, 169, 24, 1, 0, 8, 252, 0, 0, 3},

//flow 255
{26, 255, 172, 22, 0, 0, 9, 255, 0, 0, 1},
{27, 255, 172, 23, 0, 0, 9, 255, 0, 0, 1},
{29, 255, 162, 24, 1, 0, 9, 255, 0, 0, 1},
{30, 172, 173, 22, 0, 0, 9, 255, 0, 0, 2},
{31, 172, 173, 22, 0, 0, 9, 255, 0, 0, 2},
{32, 173, 169, 23, 0, 0, 9, 255, 0, 0, 3},
{32, 172, 163, 24, 1, 0, 9, 255, 0, 0, 2},
{33, 173, 169, 24, 0, 0, 9, 255, 0, 0, 3},
{33, 163, 161, 22, 1, 0, 9, 255, 0, 0, 3},
{34, 162, 173, 22, 1, 0, 9, 255, 0, 0, 2},
{35, 173, 169, 23, 1, 0, 9, 255, 0, 0, 3},
{36, 173, 161, 24, 1, 0, 9, 255, 0, 0, 3},

//flow 254
{28, 254, 172, 24, 0, 1, 10, 254, 0, 0, 1},
{29, 254, 172, 22, 0, 1, 10, 254, 0, 0, 1},
{30, 254, 162, 23, 1, 1, 10, 254, 0, 0, 1},
{31, 162, 163, 23, 1, 1, 10, 254, 0, 0, 2},
{34, 163, 161, 23, 1, 1, 10, 254, 0, 0, 3},
{37, 172, 173, 22, 0, 1, 10, 254, 0, 0, 2},
{38, 172, 173, 23, 0, 1, 10, 254, 0, 0, 2},
{39, 173, 169, 24, 0, 1, 10, 254, 0, 0, 3},
{39, 172, 163, 22, 1, 1, 10, 254, 0, 0, 2},
{40, 173, 169, 22, 0, 1, 10, 254, 0, 0, 3},
{40, 163, 161, 23, 1, 1, 10, 254, 0, 0, 3},
{41, 173, 161, 23, 1, 1, 10, 254, 0, 0, 3},

//Transmission schedule for plant #1,downlink
//This part is calculated manually by Lanshun

//flow 180
{41, 169, 173, 22, 0, 0, 11, 180, 0, 0, 1},
{42, 169, 173, 23, 0, 0, 11, 180, 0, 0, 1},
{43, 173, 172, 24, 0, 0, 11, 180, 0, 0, 2},
{44, 173, 172, 22, 0, 0, 11, 180, 0, 0, 2},
{45, 172, 180, 23, 0, 0, 11, 180, 0, 0, 3},
{46, 172, 180, 24, 0, 0, 11, 180, 0, 0, 3},

{43, 169, 163, 22, 1, 0, 11, 180, 0, 0, 1},
{44, 163, 162, 24, 1, 0, 11, 180, 0, 0, 2},
{47, 162, 180, 23, 1, 0, 11, 180, 0, 0, 3},

{44, 173, 162, 24, 1, 0, 11, 180, 0, 0, 2},
{47, 162, 180, 23, 1, 0, 11, 180, 0, 0, 3},

//flow 157
{42, 161, 160, 22, 0, 0, 12, 157, 0, 0, 1},
{43, 161, 160, 23, 0, 0, 12, 157, 0, 0, 1},
{44, 160, 170, 23, 0, 0, 12, 157, 0, 0, 2},
{45, 160, 170, 24, 0, 0, 12, 157, 0, 0, 2},
{46, 170, 157, 22, 0, 0, 12, 157, 0, 0, 3},
{47, 170, 157, 24, 0, 0, 12, 157, 0, 0, 3},

{45, 161, 163, 22, 1, 0, 12, 157, 0, 0, 1},
{46, 163, 171, 23, 1, 0, 12, 157, 0, 0, 2},
{47, 171, 157, 22, 1, 0, 12, 157, 0, 0, 3},

{46, 160, 171, 23, 1, 0, 12, 157, 0, 0, 2},
{47, 171, 157, 22, 1, 0, 12, 157, 0, 0, 3},

//Transmission schedule for plant #2,downlink
//This part is calculated manually by Lanshun

//flow 108
{48, 169, 173, 22, 0, 0, 13, 108, 0, 0, 1},
{49, 169, 173, 23, 0, 0, 13, 108, 0, 0, 1},
{50, 173, 172, 24, 0, 0, 13, 108, 0, 0, 2},
{51, 173, 172, 22, 0, 0, 13, 108, 0, 0, 2},
{52, 172, 108, 23, 0, 0, 13, 108, 0, 0, 3},
{53, 172, 108, 24, 0, 0, 13, 108, 0, 0, 3},

{50, 169, 163, 22, 1, 0, 13, 108, 0, 0, 1},
{51, 163, 162, 24, 1, 0, 13, 108, 0, 0, 2},
{54, 162, 108, 22, 1, 0, 13, 108, 0, 0, 3},

{52, 173, 162, 24, 1, 0, 13, 108, 0, 0, 2},
{53, 162, 108, 23, 1, 0, 13, 108, 0, 0, 3},

//flow 175
{48, 161, 160, 23, 0, 0, 14, 175, 0, 0, 1},
{49, 161, 160, 24, 0, 0, 14, 175, 0, 0, 1},
{50, 160, 170, 23, 0, 0, 14, 175, 0, 0, 2},
{51, 160, 170, 23, 0, 0, 14, 175, 0, 0, 2},
{53, 170, 175, 22, 0, 0, 14, 175, 0, 0, 3},
{54, 170, 175, 24, 0, 0, 14, 175, 0, 0, 3},

{50, 161, 163, 22, 1, 0, 14, 175, 0, 0, 1},
{52, 163, 171, 22, 1, 0, 14, 175, 0, 0, 2},
{53, 171, 175, 23, 1, 0, 14, 175, 0, 0, 3},

{52, 160, 171, 22, 1, 0, 14, 175, 0, 0, 2},
{53, 171, 175, 23, 1, 0, 14, 175, 0, 0, 3}
};

uint8_t schedule_len=164;
uint32_t superframe_length = 53; //Real superframe length

/*uint8_t schedule[164][11]={//PSS for 2 plants by Lanshun
//flow 181
{1, 181, 170, 22, 0, 0, 1, 181, 0, 0, 1},
{2, 181, 170, 23, 0, 0, 1, 181, 0, 0, 1},
{3, 170, 160, 24, 0, 0, 1, 181, 0, 0, 2},
{4, 170, 160, 22, 0, 0, 1, 181, 0, 0, 2},
{5, 160, 161, 23, 0, 0, 1, 181, 0, 0, 3},
{6, 160, 161, 24, 0, 0, 1, 181, 0, 0, 3},

{3, 181, 171, 22, 1, 0, 1, 181, 0, 0, 1},
{7, 171, 160, 22, 1, 0, 1, 181, 0, 0, 2},
{8, 160, 161, 23, 1, 0, 1, 181, 0, 0, 3},

{5, 170, 163, 24, 1, 0, 1, 181, 0, 0, 2},
{7, 163, 161, 23, 1, 0, 1, 181, 0, 0, 3},

{9, 160, 169, 24, 1, 0, 1, 181, 0, 0, 3},

//flow 153
{1, 153, 171, 23, 0, 0, 2, 153, 0, 0, 1},
{2, 153, 171, 24, 0, 0, 2, 153, 0, 0, 1},
{4, 171, 163, 23, 0, 0, 2, 153, 0, 0, 2},
{6, 171, 163, 22, 0, 0, 2, 153, 0, 0, 2},
{8, 163, 169, 24, 0, 0, 2, 153, 0, 0, 3},
{10, 163, 169, 22, 0, 0, 2, 153, 0, 0, 3},

{9, 153, 170, 22, 1, 0, 2, 153, 0, 0, 1},
{10, 170, 160, 23, 1, 0, 2, 153, 0, 0, 2},
{11, 160, 161, 23, 1, 0, 2, 153, 0, 0, 3},

{10, 171, 160, 23, 1, 0, 2, 153, 0, 0, 2},
{11, 160, 161, 23, 1, 0, 2, 153, 0, 0, 3},

{11, 163, 161, 23, 1, 0, 2, 153, 0, 0, 3},

//flow 152
{1, 152, 162, 24, 0, 0, 3, 152, 0, 0, 1},
{2, 152, 162, 22, 0, 0, 3, 152, 0, 0, 1},
{3, 162, 173, 23, 0, 0, 3, 152, 0, 0, 2},
{4, 162, 173, 24, 0, 0, 3, 152, 0, 0, 2},
{5, 173, 169, 22, 0, 0, 3, 152, 0, 0, 3},
{6, 173, 169, 23, 0, 0, 3, 152, 0, 0, 3},

{3, 152, 171, 22, 1, 0, 3, 152, 0, 0, 1},
{5, 171, 163, 24, 1, 0, 3, 152, 0, 0, 2},
{9, 163, 169, 24, 1, 0, 3, 152, 0, 0, 3},

{5, 162, 163, 24, 1, 0, 3, 152, 0, 0, 2},
{12, 163, 161, 23, 1, 0, 3, 152, 0, 0, 3},

{7, 173, 161, 23, 1, 0, 3, 152, 0, 0, 3},

//flow 155
{7, 155, 172, 24, 0, 0, 4, 155, 0, 0, 1},
{8, 155, 172, 22, 0, 0, 4, 155, 0, 0, 1},
{9, 172, 173, 23, 0, 0, 4, 155, 0, 0, 2},
{10, 172, 173, 24, 0, 0, 4, 155, 0, 0, 2},
{11, 173, 169, 24, 0, 0, 4, 155, 0, 0, 3},
{12, 173, 169, 24, 0, 0, 4, 155, 0, 0, 3},

{12, 155, 162, 22, 1, 0, 4, 155, 0, 0, 1},
{13, 162, 173, 22, 1, 0, 4, 155, 0, 0, 2},
{14, 173, 169, 23, 1, 0, 4, 155, 0, 0, 3},

{13, 172, 163, 23, 1, 0, 4, 155, 0, 0, 2},
{14, 163, 161, 24, 1, 0, 4, 155, 0, 0, 3},

{15, 173, 161, 24, 1, 0, 4, 155, 0, 0, 3},

//flow 154
{1, 154, 172, 24, 2, 1, 5, 154, 0, 0, 1},
{2, 154, 172, 22, 2, 1, 5, 154, 0, 0, 1},
{3, 172, 173, 23, 2, 1, 5, 154, 0, 0, 2},
{4, 172, 173, 24, 2, 1, 5, 154, 0, 0, 2},
{8, 173, 169, 24, 2, 1, 5, 154, 0, 0, 3},
{16, 173, 169, 22, 2, 1, 5, 154, 0, 0, 3},

{12, 154, 162, 22, 1, 1, 5, 154, 0, 0, 1},
{15, 162, 163, 22, 1, 1, 5, 154, 0, 0, 2},
{16, 163, 161, 23, 1, 1, 5, 154, 0, 0, 3},

{5, 172, 163, 24, 1, 1, 5, 154, 0, 0, 2},
{16, 163, 161, 23, 1, 1, 5, 154, 0, 0, 3},

{17, 173, 161, 23, 1, 1, 5, 154, 0, 0, 3},

//flow 182
{18, 182, 170, 22, 0, 0, 6, 182, 0, 0, 1},
{19, 182, 170, 23, 0, 0, 6, 182, 0, 0, 1},
{20, 170, 160, 24, 0, 0, 6, 182, 0, 0, 2},
{21, 170, 160, 22, 0, 0, 6, 182, 0, 0, 2},
{22, 160, 161, 23, 0, 0, 6, 182, 0, 0, 3},
{23, 160, 161, 24, 0, 0, 6, 182, 0, 0, 3},

{20, 182, 171, 22, 1, 0, 6, 182, 0, 0, 1},
{24, 171, 160, 22, 1, 0, 6, 182, 0, 0, 2},
{25, 160, 161, 23, 1, 0, 6, 182, 0, 0, 3},

{22, 170, 163, 24, 1, 0, 6, 182, 0, 0, 2},
{24, 163, 161, 23, 1, 0, 6, 182, 0, 0, 3},

{26, 160, 169, 24, 1, 0, 6, 182, 0, 0, 3},

//flow 253
{18, 253, 171, 23, 0, 0, 7, 253, 0, 0, 1},
{19, 253, 171, 24, 0, 0, 7, 253, 0, 0, 1},
{21, 171, 163, 23, 0, 0, 7, 253, 0, 0, 2},
{23, 171, 163, 22, 0, 0, 7, 253, 0, 0, 2},
{25, 163, 169, 24, 0, 0, 7, 253, 0, 0, 3},
{27, 163, 169, 22, 0, 0, 7, 253, 0, 0, 3},

{26, 253, 170, 22, 1, 0, 7, 253, 0, 0, 1},
{27, 170, 160, 23, 1, 0, 7, 253, 0, 0, 2},
{28, 160, 161, 23, 1, 0, 7, 253, 0, 0, 3},

{27, 171, 160, 23, 1, 0, 7, 253, 0, 0, 2},
{28, 160, 161, 23, 1, 0, 7, 253, 0, 0, 3},

{28, 163, 161, 23, 1, 0, 7, 253, 0, 0, 3},

//flow 252
{18, 252, 162, 24, 0, 0, 8, 252, 0, 0, 1},
{19, 252, 162, 22, 0, 0, 8, 252, 0, 0, 1},
{20, 162, 173, 23, 0, 0, 8, 252, 0, 0, 2},
{21, 162, 173, 24, 0, 0, 8, 252, 0, 0, 2},
{22, 173, 169, 22, 0, 0, 8, 252, 0, 0, 3},
{23, 173, 169, 23, 0, 0, 8, 252, 0, 0, 3},

{20, 252, 171, 22, 1, 0, 8, 252, 0, 0, 1},
{22, 171, 163, 24, 1, 0, 8, 252, 0, 0, 2},
{26, 163, 169, 24, 1, 0, 8, 252, 0, 0, 3},

{22, 162, 163, 24, 1, 0, 8, 252, 0, 0, 2},
{29, 163, 161, 23, 1, 0, 8, 252, 0, 0, 3},

{24, 173, 161, 23, 1, 0, 8, 252, 0, 0, 3},

//flow 255
{24, 255, 172, 24, 0, 0, 9, 255, 0, 0, 1},
{25, 255, 172, 22, 0, 0, 9, 255, 0, 0, 1},
{26, 172, 173, 23, 0, 0, 9, 255, 0, 0, 2},
{27, 172, 173, 24, 0, 0, 9, 255, 0, 0, 2},
{28, 173, 169, 24, 0, 0, 9, 255, 0, 0, 3},
{29, 173, 169, 24, 0, 0, 9, 255, 0, 0, 3},

{29, 255, 162, 22, 1, 0, 9, 255, 0, 0, 1},
{30, 162, 173, 22, 1, 0, 9, 255, 0, 0, 2},
{31, 173, 169, 23, 1, 0, 9, 255, 0, 0, 3},

{30, 172, 163, 23, 1, 0, 9, 255, 0, 0, 2},
{31, 163, 161, 24, 1, 0, 9, 255, 0, 0, 3},

{32, 173, 161, 24, 1, 0, 9, 255, 0, 0, 3},

//flow 154
{18, 254, 172, 24, 2, 1, 10, 254, 0, 0, 1},
{19, 254, 172, 22, 2, 1, 10, 254, 0, 0, 1},
{20, 172, 173, 23, 2, 1, 10, 254, 0, 0, 2},
{21, 172, 173, 24, 2, 1, 10, 254, 0, 0, 2},
{25, 173, 169, 24, 2, 1, 10, 254, 0, 0, 3},
{33, 173, 169, 22, 2, 1, 10, 254, 0, 0, 3},

{29, 254, 162, 22, 1, 1, 10, 254, 0, 0, 1},
{32, 162, 163, 22, 1, 1, 10, 254, 0, 0, 2},
{33, 163, 161, 23, 1, 1, 10, 254, 0, 0, 3},

{22, 172, 163, 24, 1, 1, 10, 254, 0, 0, 2},
{33, 163, 161, 23, 1, 1, 10, 254, 0, 0, 3},

{34, 173, 161, 23, 1, 1, 10, 254, 0, 0, 3},

//flow 180
{35, 169, 173, 22, 0, 0, 11, 180, 0, 0, 1},
{36, 169, 173, 23, 0, 0, 11, 180, 0, 0, 1},
{37, 173, 172, 24, 0, 0, 11, 180, 0, 0, 2},
{38, 173, 172, 22, 0, 0, 11, 180, 0, 0, 2},
{39, 172, 180, 23, 0, 0, 11, 180, 0, 0, 3},
{40, 172, 180, 24, 0, 0, 11, 180, 0, 0, 3},

{37, 169, 163, 22, 1, 0, 11, 180, 0, 0, 1},
{38, 163, 162, 24, 1, 0, 11, 180, 0, 0, 2},
{41, 162, 180, 23, 1, 0, 11, 180, 0, 0, 3},

{39, 173, 162, 22, 1, 0, 11, 180, 0, 0, 2},
{41, 162, 180, 23, 1, 0, 11, 180, 0, 0, 3},

//flow 157
{35, 161, 160, 23, 0, 0, 12, 157, 0, 0, 1},
{36, 161, 160, 24, 0, 0, 12, 157, 0, 0, 1},
{37, 160, 170, 22, 0, 0, 12, 157, 0, 0, 2},
{38, 160, 170, 23, 0, 0, 12, 157, 0, 0, 2},
{39, 170, 157, 24, 0, 0, 12, 157, 0, 0, 3},
{40, 170, 157, 22, 0, 0, 12, 157, 0, 0, 3},

{37, 161, 163, 22, 1, 0, 12, 157, 0, 0, 1},
{40, 163, 171, 23, 1, 0, 12, 157, 0, 0, 2},
{41, 171, 157, 22, 1, 0, 12, 157, 0, 0, 3},

{40, 160, 171, 23, 1, 0, 12, 157, 0, 0, 2},
{41, 171, 157, 22, 1, 0, 12, 157, 0, 0, 3},

//flow 108
{42, 169, 173, 22, 0, 0, 13, 108, 0, 0, 1},
{43, 169, 173, 23, 0, 0, 13, 108, 0, 0, 1},
{44, 173, 172, 24, 0, 0, 13, 108, 0, 0, 2},
{45, 173, 172, 22, 0, 0, 13, 108, 0, 0, 2},
{46, 172, 108, 23, 0, 0, 13, 108, 0, 0, 3},
{47, 172, 108, 24, 0, 0, 13, 108, 0, 0, 3},

{44, 169, 163, 22, 1, 0, 13, 108, 0, 0, 1},
{45, 163, 162, 24, 1, 0, 13, 108, 0, 0, 2},
{48, 162, 108, 23, 1, 0, 13, 108, 0, 0, 3},

{46, 173, 162, 22, 1, 0, 13, 108, 0, 0, 2},
{48, 162, 108, 23, 1, 0, 13, 108, 0, 0, 3},

//flow 175
{42, 161, 160, 23, 0, 0, 14, 175, 0, 0, 1},
{43, 161, 160, 24, 0, 0, 14, 175, 0, 0, 1},
{44, 160, 170, 22, 0, 0, 14, 175, 0, 0, 2},
{45, 160, 170, 23, 0, 0, 14, 175, 0, 0, 2},
{46, 170, 175, 24, 0, 0, 14, 175, 0, 0, 3},
{47, 170, 175, 22, 0, 0, 14, 175, 0, 0, 3},

{44, 161, 163, 22, 1, 0, 14, 175, 0, 0, 1},
{47, 163, 171, 23, 1, 0, 14, 175, 0, 0, 2},
{48, 171, 175, 22, 1, 0, 14, 175, 0, 0, 3},

{47, 160, 171, 23, 1, 0, 14, 175, 0, 0, 2},
{48, 171, 175, 22, 1, 0, 14, 175, 0, 0, 3}
};
uint8_t schedule_len = 164;
uint32_t superframe_length = 48; //Real superframe length
*/	
	bool sync;
	bool requestStop;
	uint32_t sync_count=0;
	event void Boot.booted(){}
	command error_t Init.init() {		
		slotSize = 10 * 32;     //10ms		
		//bi = 16; //# of slots from original TDMA code
		//sd = 11; //last active slot from original TDMA code
		
		bi = 40000; //# of slots in the supersuperframe with only one slot 0 doing sync
		sd = 40000; //last active slot
		// The bottom line is that we want the network to be synchronized once and keep running
		// while recycling through 0- superframe_length, because Simulink cannot stop in the middle
		
		cap = 0; // what is this used for? is this yet another superframe length?
		coordinatorId = 0;
		init = FALSE;
		toSend = NULL;
		toSendLen = 0;
		sync = FALSE;
		requestStop = FALSE;
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
 				printf("This is sensor: %u and I have done network synchronization at the slot: %u\n", TOS_NODE_ID, slot % superframe_length);
 			};
 			return;	
 		}
  		if ((slot % superframe_length) == 0 ) {
 			if (TOS_NODE_ID ==161){
 				printf("******Sensor: %u, is resetting its time slot by normalization.\n", TOS_NODE_ID);
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
 			if(TOS_NODE_ID==181){
 				printf("Slot checking, this is Sensor: %u and current time slot is: %u\n", TOS_NODE_ID, slot);
 			}	
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
		if(TOS_NODE_ID==161 || TOS_NODE_ID==169){
			//printf("FLOW:%u RECEIVED: %u->%u, SLOT:%u (time: %s), channel: %u\n", flow_id_rcv, src, TOS_NODE_ID, call SlotterControl.getSlot(), sim_time_string(), call CC2420Config.getChannel());
			//Flow ID, Delay(Slot when received), sender, receiver, channel, physical time.
			
			printf("%u, SLOT: %u, %u, %u, %u\n", flow_id_rcv, call SlotterControl.getSlot() % superframe_length, src, TOS_NODE_ID, call CC2420Config.getChannel());
			//fflush(stdout);
			//call TossimComPrintfWrite.printfWrite(flow_id_rcv, call SlotterControl.getSlot() % superframe_length, src, TOS_NODE_ID, call CC2420Config.getChannel()); //writing results to file, differentiated by file name 
			//printf("This is Sensor: %u, and we have just called TossimComPrintfWrite.printfWrite, at Slot: %u\n", TOS_NODE_ID, call SlotterControl.getSlot() % superframe_length);	
		
			//below is the tcp approach based on a global variable on each sensor, tcp_msg, defined in SimMoteP.nc added by Bo			
			call SimMote.setTcpMsg(flow_id_rcv, call SlotterControl.getSlot() % superframe_length, src, TOS_NODE_ID, call CC2420Config.getChannel());
		
		
		}else if(TOS_NODE_ID == 157 || TOS_NODE_ID == 180 || TOS_NODE_ID == 108 || TOS_NODE_ID == 175){
			//printf("FLOW:%u RECEIVED: %u->%u, SLOT:%u (time: %s), channel: %u\n", flow_id_rcv, src, TOS_NODE_ID, call SlotterControl.getSlot(), sim_time_string(), call CC2420Config.getChannel());
			//Flow ID, Delay(Slot when received), sender, receiver, channel, physical time.
			
			//below is the file appraoch
			printf("%u, SLOT: %u, %u, %u, %u\n", flow_id_rcv, call SlotterControl.getSlot() % superframe_length, src, TOS_NODE_ID, call CC2420Config.getChannel());
			//call TossimComPrintfWrite.printfWrite(flow_id_rcv, call SlotterControl.getSlot() % superframe_length, src, TOS_NODE_ID, call CC2420Config.getChannel()); //writing results to file, differentiated by file name
			//printf("This is Sensor: %u, and we have just called TossimComPrintfWrite.printfWrite, at Slot: %u\n", TOS_NODE_ID, call SlotterControl.getSlot() % superframe_length);
			
			//below is the tcp approach based on a global variable on each sensor, tcp_msg, defined in SimMoteP.nc added by Bo			
			call SimMote.setTcpMsg(flow_id_rcv, call SlotterControl.getSlot() % superframe_length, src, TOS_NODE_ID, call CC2420Config.getChannel());
		}
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
 		atomic bi = numSlots;
		call FrameConfiguration.setFrameLength(bi+1);
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
}