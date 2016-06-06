/*
 * Copyright (c) 2008 Polaric
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of Polaric nor the names of its contributors may
 *   be used to endorse or promote products derived from this software
 *   without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
 * CONTRIBUTORS ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL POLARIC OR ITS CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 *
 * @author Martin Leopold <leopold@polaric.dk>
 */

configuration PlatformLedsC
{
  provides interface GeneralIO as Led0;
  provides interface GeneralIO as Led1;
  provides interface GeneralIO as Led2;

  uses interface Init;
}
implementation
{
  components Hplcip51GeneralIOC,
    new ReverseGPIOP() as Led0_rev,
    new ReverseGPIOP() as Led1_rev,
    new ReverseGPIOP() as Led2_rev,
    PlatformP,
    new NoPinC();


  /* 
   * The bizare Led interface assumes that the led pins are active low
   * and LedsP set the corresponding pin low...
   *
   * ReverseGPIOP reverses the semantics of clr/set in GeneralIO
   */

  Led0_rev.In -> Hplcip51GeneralIOC.P22;
  Led1_rev.In -> Hplcip51GeneralIOC.P23;
  Led2_rev.In -> NoPinC;

  Led0 = Led0_rev.Out;
  Led1 = Led1_rev.Out;
  Led2 = Led2_rev.Out;

  Init = PlatformP.LedsInit;
}
