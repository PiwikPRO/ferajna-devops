CREATE DATABASE ferajna ON CLUSTER default;

CREATE TABLE ferajna.events_shard ON CLUSTER default
(
    `WatchID` UInt64,
    `JavaEnable` UInt8,
    `Title` String,
    `GoodEvent` Int16,
    `EventTime` DateTime,
    `EventDate` Date
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/ferajna/{shard}/events', '{replica}', EventDate, (EventDate), 8192);

CREATE TABLE ferajna.events ON CLUSTER default
(
    `WatchID` UInt64,
    `JavaEnable` UInt8,
    `Title` String,
    `GoodEvent` Int16,
    `EventTime` DateTime,
    `EventDate` Date
)
ENGINE = Distributed(default, "ferajna", events_shard, rand());
