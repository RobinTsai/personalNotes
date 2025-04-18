# graphviz

## ads-fsm.dot

```
strict digraph {
  label = <ADS state machine<br/> >
  labelloc = "t";

  Start -> Start [label="EC_Create (EC=ChannelEvt)"]
  Start -> UserAnswer [label=EC_Answer]
  Start -> FailEnd [label=EC_Hangup]

  UserAnswer -> UserAnswer [label=EC_Create]
  UserAnswer -> Talking [label=EC_Answer]
  UserAnswer -> FailEnd [label=EC_Hangup]

  Talking -> SuccEnd [label=FsEvtChannelHangup]
}

```

## test.dotuml

```
SequenceDiagram {
 lifeline "a" as 3563413
 lifeline "A_in" as 355060
 lifeline "A_out" as 355080
 lifeline "B_out" as 1705080
 lifeline "B_in" as 1705060
 lifeline "b" as 17050471

 3563413 --> 355060 "26. INVITE sip:01000@35"
 355060 -r-> 3563413 "27. 100 Trying"
 355060 -r-> 3563413 "30. 407 Proxy Authentication Required"
 3563413 --> 355060 "33. ACK sip:01000@35"
 note over 3563413,355060 "done auth"

 3563413 --> 355060 "34. INVITE sip:01000@35"
 355060 -r-> 3563413 "35. 100 Trying"
 355080 --> 1705080 "40. INVITE sip:1000@170:5080"
 1705080 -r-> 355080 "41. 100 Trying"
//  355080 --> 1705080 "54. INVITE sip:1000@170:5080"
//  1705080 -r-> 355080 "55. 100 Trying"
 355060 -r-> 3563413 "128. 183 Session Progress"
//  1705080 -r-> 355080 "145. 183 Session Progress"
 1705060 --> 17050471 "304. INVITE sip:1000@170:50471;ob"
 17050471 -r-> 1705060 "306. 100 Trying"
 17050471 -r-> 1705060 "307. 180 Ringing"
 1705080 -r-> 355080 "308. 183 Session Progress"
//  1705080 -r-> 355080 "444. 200 OK"
//  355080 --> 1705080 "446. ACK sip:1000@170:5080;transport=udp"
//  1705080 --> 355080 "449. INFO sip:mod_sofia@35:5080"
//  355080 -r-> 1705080 "451. 200 OK"
//  355080 --> 1705080 "454. INFO sip:1000@170:5080;transport=udp"
//  1705080 -r-> 355080 "455. 200 OK"
 355060 -r-> 3563413 "478. 200 OK"
 3563413 --> 355060 "480. ACK sip:01000@35:5060;transport=udp"
 17050471 -r-> 1705060 "643. 200 OK"
 1705060 --> 17050471 "645. ACK sip:1000@170:50471;ob"
 1705080 -r-> 355080 "646. 200 OK"
 355080 --> 1705080 "648. ACK sip:1000@170:5080;transport=udp"
 1705080 --> 355080 "652. INFO sip:mod_sofia@35:5080"
 355080 -r-> 1705080 "654. 200 OK"
 355080 --> 1705080 "657. INFO sip:1000@170:5080;transport=udp"
 1705080 -r-> 355080 "660. 200 OK"
 note over 1705080,355080 "established call"

 17050471 --> 1705060 "996. BYE sip:mod_sofia@170:5060"
 1705060 -r-> 17050471 "997. 200 OK"
 1705080 --> 355080 "998. BYE sip:mod_sofia@35:5080"
 355080 -r-> 1705080 "999. 200 OK"
 355060 --> 3563413 "977. BYE sip:1000@35:63413;ob"
 3563413 -r-> 355060 "978. 200 OK"
}
```
