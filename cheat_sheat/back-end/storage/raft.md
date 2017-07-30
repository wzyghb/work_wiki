# raft 算法总计

reference:

+ [raft consensus Algorithm](https://raft.github.io/)
+ [raft docter paper](https://github.com/ongardie/dissertation)
+ [中文版](http://www.infoq.com/cn/articles/raft-paper)
+ [liskov](http://www.pmg.csail.mit.edu/papers/vr.pdf)
+ [printston ds mooc](https://www.cs.princeton.edu/courses/archive/fall16/cos418/syllabus.html)

## phrase

+ leader selection
+ log replication
+ safety
+ state space reduction
+ overlapping majorities
+ replicated state machine

## feature

 easy to understand (vs paxos, no need to modify for real env)

+ Stronger Leader (log only send from leader)
+ Leader Selection: random timer， can resolve conflict better and quick.
+ Membership Change: joint consensus overlap

1. Election Safety
1. Leader Append-Only
1. Log Matching
1. Leader Completeness
1. State Machine Safety

## Problem

+ 5 server cluster allow 2 server stop work
+ server state: leader, canditate, follower
