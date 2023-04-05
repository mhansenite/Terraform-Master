#!/bin/bash
echo "Adding in user mike"
useradd mike -mU -G admin  -s /bin/bash
mkdir -p /home/mike/.ssh
echo -e "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD4jS7SGn+YdgoqWBJuVF1/wwGrrrLmTT8hR4vFmLyWLxqh4YfBi7K0LfPPBk3uuUkwWF5qm9V+uirH0XTe/9Bo6FfhkplQW8TzVpkBhvREe5qlls3cq/ENKOfpE5X8f1zWVnE6XNmJgXhcmJIcB/lJOMRkzf0MCjX8czxW7LIsWzNNacp/NTwzcG1Ky/svpPBEdst9a8P6PlWOicUHbisSSW7eGo7NrEiHzeL7zH14g/04WXmFIA93iAQPpL15M5wOEEuUDjUFv4XLzNW2nlLMdinQ1qlWAaARviqvcPn5kyqTKn+mS6nwgKDSO4JJppx63jqpHKvJ24HPF7RjYohrWBfbIRz43zFkHq1SQRG7rzHDtPWBvxvyRUSjDpaWE2UVwxG7rzoha/t6UiiZFE37fQ8j2ROxIVKoQn/cMXGS/2VQ6olUY/OGwFQLEvBWq62FbJJmjchEVoG+sA9JOesJNYGKUOodd8ojubHBfts6es6iXLgnAVCpNgJ1RekX8jk=" >> /home/mike/.ssh/authorized_keys
echo -e "mike ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
chown -R mike:mike /home/mike/.ssh
chmod -R 700 /home/mike/.ssh/

echo "adding in svc-sys"
useradd svc-sys -mU -s /bin/bash

#install Docker
apt-get update
apt-get --yes install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-get update
apt-cache policy docker-ce
apt-get --yes install docker-ce
sudo usermod -aG docker svc-sys
sudo usermod -aG docker mike
sudo chmod 666 /var/run/docker.sock

#install AWS cli
mkdir /opt/aws/
cd /opt/aws/
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
apt install unzip
unzip awscliv2.zip
sudo ./aws/install

#install misc
apt-get --yes install nmon

#add ghz configs
mkdir /opt/ghz

echo '{
"proto": "/mnt/parcel.proto",
"call": "ParcelService.Search",
"data": {
"limit": 500,
"quad_keys": {
"quad_keys": [
"0231000001231",
"0231000001233",
"023100000132",
"023100000133",
"0231000003011",
"0231000003013",
"0231000003031",
"0231000003033",
"02310000031",
"0231000003211",
"0231000003300",
"0231000003301",
"0231000003310",
"0231000003311",
"0231000010220",
"0231000010222",
"0231000012000",
"0231000012002",
"0231000012020",
"0231000012022",
"0231000012200"
]
},
"lbcs_structures": {
"codes": [
"1100",
"2100",
"2300",
"2200",
"2400",
"2500",
"2600",
"2700"
],
"enableRecursive": true
}
},
"max-duration": "60s",
"timeout": "60s"
}' > /opt/ghz/config.json

echo 'syntax = "proto3";

option java_multiple_files = true;
option java_package = "com.aeonai.parcel.proto";

message Coordinate {
  double latitude = 1;
  double longitude = 2;
}

enum UsgsFloodFrequency {
  UNSPECIFIED = 0;
  VERY_FREQUENT = 1;
  FREQUENT = 2;
  OCCASIONAL = 3;
  RARE = 4;
  VERY_RARE = 5;
  NONE = 6;
  NOT_RATED = 7;
}

message UsPostalAddress {
  string raw = 1;
  string street_1 = 2;
  string street_2 = 3;
  string city = 4;
  string state = 5;
  string postal_code = 6;
}

message Parcel {
  string id = 1;
  string apn = 2;
  string owner = 24;
  UsPostalAddress address = 3;

  double acreage = 4;

  repeated string quad_keys = 5 [ deprecated = true ];
  Coordinate geo_center = 6;

  // landuse via APAs LBCS
  string lbcs_site_code = 7;
  string lbcs_structure_code = 8;
  string lbcs_activity_code = 9;
  string lbcs_function_code = 10;
  string lbcs_ownership_code = 11;

  // political entities identifiers (could also be based on census?)
  // phase 2
  string city_id = 12;
  string county_id = 13;
  string state_id = 14;

  // census identifiers (how to handle different years/versions?)
  // phase 3
  string census_2010_block_code = 15;
  string census_2010_block_group_code = 16;
  string census_2010_tract_code = 17;

  // usgs - flood frequency
  message FloodFrequencyItem {
    UsgsFloodFrequency frequency = 1;
    double percentage = 2;
  }
  repeated FloodFrequencyItem flood_frequencies = 18;

  // usgs - representative slope
  message SlopeItem {
    double slope_percentage = 1;
    double percentage = 2;
  }
  repeated SlopeItem slopes = 19;

  message CarsPerDayItem {
    int32 adjacent = 1;
    int32 quarter_mile = 2;
    int32 half_mile = 3;
    int32 full_mile = 4;
  }
  CarsPerDayItem cars_per_day = 20;

  message MedianHouseholdIncomeValue {
    double value = 1;
  }

  message MedianHouseholdIncomeItem {
    MedianHouseholdIncomeValue mile_1 = 1;
    MedianHouseholdIncomeValue mile_3 = 2;
    MedianHouseholdIncomeValue mile_5 = 3;
  }
  MedianHouseholdIncomeItem median_household_income = 25;

  message DistanceToAirportItem {
    message Airport {
      string id = 1;
      string name = 2;
      Coordinate coordinate = 3;
    }

    Airport airport = 1;
    int32 minutes = 2;
    double miles = 3;
  }
  repeated DistanceToAirportItem airports = 21;

  message DistanceToMetroStationItem {
    message MetroStation {
      string id = 1;
      string name = 2;
      Coordinate coordinate = 3;
    }

    MetroStation metro_station = 1;
    int32 walking_minutes = 2;
    double walking_miles = 3;
    int32 biking_minutes = 4;
    double biking_miles = 5;
  }
  repeated DistanceToMetroStationItem metro_stations = 22;

  message DistanceToBusStopItem {
    message BusStop {
      string id = 1;
      string name = 2;
      Coordinate coordinate = 3;
    }

    BusStop bus_stop = 1;
    int32 walking_minutes = 2;
    double walking_miles = 3;
    int32 biking_minutes = 4;
    double biking_miles = 5;
  }
  repeated DistanceToBusStopItem bus_stops = 23;

  // TODO:
  // census statistics / market research stats
}

message LoadParcelRequest { repeated string ids = 1; }
message LoadParcelResponse {
  message ResponseItem {
    Parcel parcel = 1;
    string error = 2;
  }
  repeated ResponseItem results = 1;
}

message LoadParcelGeometryRequest { repeated string ids = 1; }
message LoadParcelGeometryResponse {
  message ResponseItem {
    string geojson_geometry = 1;
    string error = 2;
  }
  repeated ResponseItem results = 1;
}

message LoadParcelQuadKeysRequest { repeated string ids = 1; }
message LoadParcelQuadKeysResponse {
  message ResponseItem {
    repeated string quad_keys = 1;
    string error = 2;
  }
  repeated ResponseItem results = 1;
}

message SearchParcelRequest {
  int32 limit = 1;
  int32 offset = 2;

  message QuadKeyFilter {
    // acts as an OR
    repeated string quad_keys = 1;
    bool disable_recursive = 2;
  }
  QuadKeyFilter quad_keys = 3;

  message LbcsFilter {
    // acts as an OR
    repeated string codes = 1;
    bool enable_recursive = 2;
    bool include_unknown = 3;
  }
  LbcsFilter lbcs_sites = 4;
  LbcsFilter lbcs_structures = 5;
  LbcsFilter lbcs_actitivies = 6;
  LbcsFilter lbcs_functions = 7;
  LbcsFilter lbcs_ownership = 8;

  message AcreageFilter {
    double min = 1;
    double max = 2;
  }
  AcreageFilter acreage = 9;
  string keywords = 10;

  message FloodFrequencyFilter {
    // acts as an OR
    repeated UsgsFloodFrequency frequency = 1;
    bool include_unknown = 2;
  }
  FloodFrequencyFilter flood_frequencies = 11;

  message SlopeFilter {
    double min = 1;
    double max = 2;
  }
  SlopeFilter slope = 12;

  message CarsPerDayFilter {
    enum Radius {
      UNSPECIFIED = 0;
      ADJACENT = 1;
      QUARTER = 2;
      HALF = 3;
      FULL = 4;
    }
    Radius radius = 1;
    int32 min = 2;
    int32 max = 3;
  }
  CarsPerDayFilter cars_per_day = 13;

  message AirportCarDistanceMinutesFilter {
    int32 min = 2;
    int32 max = 3;
  }
  AirportCarDistanceMinutesFilter airport_distance = 14;

  message MetroStationDistanceMinutesFilter {
    enum Transportation {
      UNSPECIFIED = 0;
      WALK = 1;
      BIKE = 2;
    }
    Transportation transportation = 1;
    int32 min = 2;
    int32 max = 3;
  }
  MetroStationDistanceMinutesFilter metro_station_distance = 15;

  message BusStopDistanceMinutesFilter {
    enum Transportation {
      UNSPECIFIED = 0;
      WALK = 1;
      BIKE = 2;
    }
    Transportation transportation = 1;
    int32 min = 2;
    int32 max = 3;
  }
  BusStopDistanceMinutesFilter bus_stop_distance = 16;

  message MedianHouseholdIncomeFilter {
    enum Radius {
      UNSPECIFIED = 0;
      MILE_1 = 1;
      MILE_3 = 2;
      MILE_5 = 3;
    }
    Radius radius = 1;
    int32 min = 2;
    int32 max = 3;
  }
  MedianHouseholdIncomeFilter median_household_income = 17;
}

message SearchParcelResponse {
  int32 total = 1;
  repeated Parcel results = 2;
}

service ParcelService {
  rpc LoadParcel(LoadParcelRequest) returns (LoadParcelResponse);
  rpc LoadParcelGeometry(LoadParcelGeometryRequest)
      returns (LoadParcelGeometryResponse);
  rpc LoadParcelQuadKeys(LoadParcelQuadKeysRequest)
      returns (LoadParcelQuadKeysResponse);
  rpc Search(SearchParcelRequest) returns (SearchParcelResponse);
}' > /opt/ghz/parcel.proto
cd opt/ghz
