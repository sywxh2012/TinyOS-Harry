/*
 * Copyright (c) 2005-2006 Rincon Research Corporation
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
 * - Neither the name of the Rincon Research Corporation nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
 * ARCHED ROCK OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE
 */

/**
 * Automatically generated header file for BFileRead
 */
 
#include "BFileRead.h"
#include "BlackbookConst.h"

module Link_BFileReadP {
  uses {
    interface BFileRead;
    
    interface AMSend as SerialReplySend;
    interface AMSend as SerialEventSend;
    interface Receive as SerialReceive;
    interface Packet as SerialPacket;
    interface AMPacket as SerialAMPacket;
    
    /** No radio
    interface AMSend as RadioReplySend;
    interface AMSend as RadioEventSend;
    interface Receive as RadioReceive;
    interface Packet as RadioPacket;
    interface AMPacket as RadioAMPacket;
    interface MessageTransport;
    */
  }
}

implementation {

  /** Message to reply with return values */
  message_t replyMsg;
  
  /** Message to signal events */
  message_t eventMsg;
  
  /** TRUE if we are to reply to serial, FALSE to radio */
  bool sendSerial;
  
  /** Destination address to reply to */
  am_addr_t destination;
  
  
  /***************** Prototypes *****************/
  void execute(BFileReadMsg *inMsg, BFileReadMsg *replyPayload);
  task void sendEventMsg();
  task void sendReplyMsg();
  
  /***************** Receive Events ****************/
  
  event message_t *SerialReceive.receive(message_t *msg, void *payload, uint8_t len) {
    sendSerial = TRUE;
    destination = call SerialAMPacket.source(msg);
    execute(payload, call SerialPacket.getPayload(&replyMsg, NULL));
    return msg;
  }
  
  
  /** No radio
  event message_t *RadioReceive.receive(message_t *msg, void *payload, uint8_t len) {
    sendSerial = FALSE;
    destination = call RadioAMPacket.source(msg);
    execute(payload, call RadioPacket.getPayload(&replyMsg, NULL));
    return msg;
  }
  */
  
  /***************** Send Events ****************/
  
  event void SerialReplySend.sendDone(message_t *msg, error_t error) {
  }
  
  event void SerialEventSend.sendDone(message_t *msg, error_t error) {
  }
  
  
  /** No radio
  event void RadioReplySend.sendDone(message_t *msg, error_t error) {
  }
  
  event void RadioEventSend.sendDone(message_t *msg, error_t error) {
  }
  */
  
  /***************** BFileRead Events ****************/
  event void BFileRead.opened(uint32_t amount, error_t error) {
    ((BFileReadMsg *) call SerialPacket.getPayload(&eventMsg, NULL))->short0 = EVENT_OPENED;
    ((BFileReadMsg *) call SerialPacket.getPayload(&eventMsg, NULL))->long0 = amount;
    ((BFileReadMsg *) call SerialPacket.getPayload(&eventMsg, NULL))->short1 = error;
    post sendEventMsg();
  }  
  
  event void BFileRead.closed(error_t error) {
    ((BFileReadMsg *) call SerialPacket.getPayload(&eventMsg, NULL))->short0 = EVENT_CLOSED;
    ((BFileReadMsg *) call SerialPacket.getPayload(&eventMsg, NULL))->short1 = error;
    post sendEventMsg();
  }  
  
  event void BFileRead.readDone(void *dataBuffer, uint16_t amount, error_t error) {
    ((BFileReadMsg *) call SerialPacket.getPayload(&eventMsg, NULL))->short0 = EVENT_READDONE;
    ((BFileReadMsg *) call SerialPacket.getPayload(&eventMsg, NULL))->int0 = amount;
    ((BFileReadMsg *) call SerialPacket.getPayload(&eventMsg, NULL))->short1 = error;
    post sendEventMsg();
  }
  
  /***************** Tasks ****************/
  task void sendReplyMsg() {
    if(sendSerial) {
      
      if(call SerialReplySend.send(destination, &replyMsg, sizeof(BFileReadMsg)) != SUCCESS) {
        post sendReplyMsg();
      }
      
      
    } else {
      /** No radio
      call MessageTransport.setRetries(&replyMsg, 10);
      call MessageTransport.setRetryDelay(&replyMsg, 0);
      if(call RadioReplySend.send(destination, &replyMsg, sizeof(BFileReadMsg)) != SUCCESS) {
        post sendReplyMsg();
      }
      */
    }
  }
  
  task void sendEventMsg() {
    if(sendSerial) {
      
      if(call SerialEventSend.send(destination, &eventMsg, sizeof(BFileReadMsg)) != SUCCESS) {
        post sendEventMsg();
      }
      
      
    } else {
      /** No radio
      call MessageTransport.setRetries(&eventMsg, 10);
      call MessageTransport.setRetryDelay(&eventMsg, 0);
      if(call RadioReplySend.send(destination, &eventMsg, sizeof(BFileReadMsg)) != SUCCESS) {
        post sendEventMsg();
      }
      */
    }
  }
      
  /***************** Functions ****************/
  void execute(BFileReadMsg *inMsg, BFileReadMsg *replyPayload) {
    memset(replyPayload, 0, sizeof(BFileReadMsg));
    switch(inMsg->short0) {
      case CMD_OPEN:
        replyPayload->short0 = REPLY_OPEN;
        replyPayload->short1 = call BFileRead.open((char *) inMsg->byteArray);
        post sendReplyMsg();
        break;

      case CMD_ISOPEN:
        replyPayload->short0 = REPLY_ISOPEN;
        replyPayload->bool0 = call BFileRead.isOpen();
        post sendReplyMsg();
        break;

      case CMD_CLOSE:
        replyPayload->short0 = REPLY_CLOSE;
        replyPayload->short1 = call BFileRead.close();
        post sendReplyMsg();
        break;

      case CMD_READ:
        replyPayload->short0 = REPLY_READ;
        memset(((BFileReadMsg *) call SerialPacket.getPayload(&eventMsg, NULL))->byteArray, 0, BFILEREAD_BYTE_ARRAY_LENGTH);
        replyPayload->short1 = call BFileRead.read(((BFileReadMsg *) call SerialPacket.getPayload(&eventMsg, NULL))->byteArray, inMsg->int0);
        post sendReplyMsg();
        break;

      case CMD_SEEK:
        replyPayload->short0 = REPLY_SEEK;
        replyPayload->short1 = call BFileRead.seek(inMsg->long0);
        post sendReplyMsg();
        break;

      case CMD_SKIP:
        replyPayload->short0 = REPLY_SKIP;
        replyPayload->short1 = call BFileRead.skip(inMsg->int0);
        post sendReplyMsg();
        break;

      case CMD_GETREMAINING:
        replyPayload->short0 = REPLY_GETREMAINING;
        replyPayload->long0 = call BFileRead.getRemaining();
        post sendReplyMsg();
        break;

      default:
    }


  }
}
