
## 快速浏览

+ [创建 keyspace](http://docs.datastax.com/en/cql/3.3/cql/cql_reference/cqlCreateKeyspace.html)
+ [创建 table](http://docs.datastax.com/en/cql/3.3/cql/cql_using/useCreateTable.html)
+ []()

## 命令示例

```
CREATE KEYSPACE IF NOT EXISTS cycling WITH REPLICATION = { 'class' : 'NetworkTopologyStrategy', 'datacenter1' : 3 };    // 创建 keyspace
USE cycling;                                                                                                            // 使用 keyspace
ALTER KEYSPACE system_auth WITH REPLICATION = {'class' : 'NetworkTopologyStrategy', 'dc1' : 3, 'dc2' : 2};              // 修改 keyspace
CREATE TABLE cycling.cyclist_alt_stats ( id UUID PRIMARY KEY, lastname text, birthday timestamp, nationality text, weight text, height text );
CREATE TABLE cycling.whimsey ( id UUID PRIMARY KEY, lastname text, cyclist_teams set<text>, events list<text>, teams map<int,text> );
CREATE TABLE cycling.route (race_id int, race_name text, point_id int, lat_long tuple<text, tuple<float,float>>, PRIMARY KEY (race_id, point_id));  // 多个 primary key

CREATE TABLE cycling.cyclist_category ( 
category text, 
points int, 
id UUID, 
lastname text,     
PRIMARY KEY (category, points)
) WITH CLUSTERING ORDER BY (points DESC);

CREATE TABLE crossfit_gyms_by_location ( 
    country_code text,
    state_province text,
    city text,
    gym_name text,
    PRIMARY KEY (country_code, state_province, city, gym_name) 
) WITH CLUSTERING ORDER BY (state_province DESC, city ASC, gym_name ASC); 

```

counter:

```
USE cycling;
CREATE TABLE popular_count (
  id UUID PRIMARY KEY,
  popularity counter
);

UPDATE cycling.popular_count
 SET popularity = popularity + 1
 WHERE id = 6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47;

SELECT * FROM cycling.popular_count;
```

[key 的定义解释](http://datascale.io/cassandra-partitioning-and-clustering-keys-explained/)