#/ Usage: ruby examples/netstat.rb | stripchart

def main
  sampler = NetstatSampler.new
  loop do
    sampler.sample
    sleep 1
  end
end

class NetstatSampler
  def sample
    data = read_netstat
    @first ||= data
    report(:current => data, :previous => @previous, :first => @first)
    @previous = data
  end

  private

  def report(x)
    current  = x.fetch :current
    previous = x.fetch :previous
    first    = x.fetch :first

    if previous
      current.each do |n,v|
        puts "#{n} #{v - previous[n]}"
      end
    end
  end

  def read_netstat
    IO.popen ["netstat", "-s", "-p", "tcp"] do |netstat|
      data = {}
      until netstat.eof?
        if netstat.readline =~ /\t(\d+) ([^\r\n]+)/
          n = $1.to_i
          label = $2
          case label
          when "packets sent", "packets received"
            data[label] = n
          when /^out-of-order packets/
            data["out-of-order"] = n
          end
        end
      end
      data
    end
  end
end

main

# netstat -s -p tcp
#    tcp:
#    	6878757 packets sent
#    		1509288 data packets (741004496 bytes)
#    		158547 data packets (106210357 bytes) retransmitted
#    		0 resends initiated by MTU discovery
#    		3818161 ack-only packets (39601 delayed)
#    		0 URG only packets
#    		16 window probe packets
#    		835713 window update packets
#    		560710 control packets
#    		0 data packets sent after flow control
#    		3062218 checksummed in software
#    			3020674 segments (485404036 bytes) over IPv4
#    			41544 segments (13408087 bytes) over IPv6
#    	7402898 packets received
#    		1507122 acks (for 730507423 bytes)
#    		264467 duplicate acks
#    		0 acks for unsent data
#    		4348305 packets (4143356951 bytes) received in-sequence
#    		92538 completely duplicate packets (43922277 bytes)
#    		1099 old duplicate packets
#    		68 packets with some dup. data (26920 bytes duped)
#    		646676 out-of-order packets (828542676 bytes)
#    		0 packets (0 bytes) of data after window
#    		0 window probes
#    		18699 window update packets
#    		10309 packets received after close
#    		226 bad resets
#    		0 discarded for bad checksums
#    		3199470 checksummed in software
#    			3160449 segments (3064756052 bytes) over IPv4
#    			39021 segments (11592028 bytes) over IPv6
#    		0 discarded for bad header offset fields
#    		0 discarded because packet too short
#    	472655 connection requests
#    	3573 connection accepts
#    	5 bad connection attempts
#    	21 listen queue overflows
#    	122395 connections established (including accepts)
#    	478728 connections closed (including 35378 drops)
#    		5105 connections updated cached RTT on close
#    		5105 connections updated cached RTT variance on close
#    		4243 connections updated cached ssthresh on close
#    	352030 embryonic connections dropped
#    	1494844 segments updated rtt (of 1747114 attempts)
#    	262235 retransmit timeouts
#    		3768 connections dropped by rexmit timeout
#    		0 connections dropped after retransmitting FIN
#    	2883 persist timeouts
#    		1 connection dropped by persist timeout
#    	6142 keepalive timeouts
#    		2201 keepalive probes sent
#    		3269 connections dropped by keepalive
#    	202525 correct ACK header predictions
#    	3940084 correct data packet header predictions
#    	67220 SACK recovery episodes
#    	27837 segment rexmits in SACK recovery episodes
#    	21705556 byte rexmits in SACK recovery episodes
#    	99492 SACK options (SACK blocks) received
#    	619398 SACK options (SACK blocks) sent
#    	0 SACK scoreboard overflow
#    	0 LRO coalesced packets
#    		0 times LRO flow table was full
#    		0 collisions in LRO flow table
#    		0 times LRO coalesced 2 packets
#    		0 times LRO coalesced 3 or 4 packets
#    		0 times LRO coalesced 5 or more packets
#    	16389 limited transmits done
#    	65822 early retransmits done
#    	20682 times cumulative ack advanced along with SACK
#
# diff out-of-order packets
# other stuff?
