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
 
#include "MicaConstants.h"

/**
 * Provides a millisecond, 16-bit Alarm, built on hardware timer 1.
 *
 * @author Greg Hackmann <ghackmann@wustl.edu>
 * @see Please refer to TEP 102 for more information about this component and
 * its intended use.
 */
generic configuration AlarmMilli16C()
{
	provides interface Alarm<TMilli, uint16_t>;
}
implementation
{	
	enum
	{
		ID = unique(UQ_MICA_TONE_16),
	};
	
	components MicaTOne16P;
	components CounterMilli16C;
	components new TransformAlarmC(TMilli, uint16_t, TOne, uint16_t,
		MICA_DIVIDE_ONE_FOR_MILLI_LOG2) as Transform;
	
	Alarm = Transform;
	Transform.AlarmFrom -> MicaTOne16P.Alarm[ID];	
	Transform.Counter -> CounterMilli16C;
}
