/*
 * "Copyright (c) 2007 Washington University in St. Louis.
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 *
 * IN NO EVENT SHALL WASHINGTON UNIVERSITY IN ST. LOUIS BE LIABLE TO ANY PARTY
 * FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING
 * OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF WASHINGTON
 * UNIVERSITY IN ST. LOUIS HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * WASHINGTON UNIVERSITY IN ST. LOUIS SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND WASHINGTON UNIVERSITY IN ST. LOUIS HAS NO
 * OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
 * MODIFICATIONS."
 */
 
/**
 * 
 * @author Greg Hackmann
 * @version $Revision: 1.2 $
 * @date $Date: 2009/06/09 17:09:59 $
 */

configuration ThroughputBenchmarkAppC
{
}
implementation
{
	components MainC;
	components CC2420ActiveMessageC;
	
	components ThroughputBenchmarkC as App;
	components new AMSenderC(240) as AMSender;
	components new AMReceiverC(240) as AMReceiver;

	components LedsC as LedsC;
	components new TimerMilliC() as BenchmarkTimer;
	components new TimerMilliC() as StartTimer;
	
	App.Boot -> MainC;
	App.Packet -> CC2420ActiveMessageC;
	App.CC2420Packet -> CC2420ActiveMessageC;
	App.SplitControl -> CC2420ActiveMessageC;
	App.AMSender -> AMSender;
	App.AMReceiver -> AMReceiver;
	App.Leds -> LedsC;
	App.BenchmarkTimer -> BenchmarkTimer;
	App.StartTimer -> StartTimer;

#ifdef UPMA
	components MacControlC;
#ifndef TDMA
	App.LowPowerListening -> MacControlC;
#endif
#ifdef SCP
	App.SyncInterval -> MacControlC;
#endif /* SCP */
#else
	App.LowPowerListening -> CC2420ActiveMessageC;
#endif /* UPMA */
}

