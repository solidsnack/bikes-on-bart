require 'net/http'
require 'uri'

require 'nokogiri'

module BARTron
extend self

  class QBall
    def initialize(api_key)
      @api_key = api_key
    end
    def query_string(params)
      q = BARTron.hash2get( params.merge('key' => @api_key) )
      "http://api.bart.gov/api/sched.aspx#{q}"
    end
    def query_text(params)
      url = self.query_string(params)
      Net::HTTP.get(URI.parse(url))
    end
    def query_xml(params)
      text = self.query_text(params)
      Nokogiri::XML(text)
    end
  end

  module Queries
  extend self
    def recent_trips(from, to)
      { 'cmd' => 'depart', 'b' => '4', 'a' => '4', 'l' => '1',
        'orig' => from,
        'dest' => to }
    end
  end

  class Q
    def initialize(qball)
      @qball = qball
    end
    def recent_trips(from, to)
      unless BARTron::STATIONS[from] and BARTron::STATIONS[to]
        { 'error' => 'bad station' }
      else
        params = BARTron::Queries.recent_trips(from, to)
        xml = @qball.query_xml(params)
        res = xml.xpath('//trip').map do |trip|
                trip.xpath('.//leg').map do |leg|
                  t0 = BARTron.timestamp_rewrite( leg['origTimeDate'],
                                                  leg['origTimeMin'] )
                  t1 = BARTron.timestamp_rewrite( leg['destTimeDate'],
                                                  leg['destTimeMin'] )
                  orig, dest = leg['origin'], leg['destination']
                  head = leg['trainHeadStation']
                  bikes = leg['bikeflag'] == '1' ? 'yes' : 'no'
                  { 'origStationAbbrev' => orig,
                    'origStation' => BARTron::STATIONS[orig],
                    'destStationAbbrev' => dest,
                    'destStation' => BARTron::STATIONS[dest],
                    'origTime' => t0,
                    'destTime' => t1,
                    'finalStationAbbrev' => head,
                    'finalStation' => BARTron::STATIONS[head],
                    'bikes' => bikes }
                end
              end
        { 'result' => res }
      end
    end
  end

  def hash2get(hash)
    # Use URL escaping some day.
    hash.inject("") do |acc, pair|
      k, v = pair
      acc.empty? ? "?#{k}=#{v}" : "#{acc}&#{k}=#{v}"
    end
  end

  def timestamp_rewrite(bart_date, bart_time)
    # Convert to UTC some day.
    month, day, year = bart_date.split('/')
    hour12, min, meridian = bart_time.split(/:| /)
    hour24 = sprintf('%02d', case meridian
                             when 'AM' then hour12.to_i
                             when 'PM' then hour12.to_i + 12
                             end )
    "#{year}-#{month}-#{day}T#{hour24}:#{min} US/Pacific"
  end

  STATIONS = { '12TH' => '12th St. Oakland City Center',
               '16TH' => '16th St. Mission (SF)',
               '19TH' => '19th St. Oakland',
               '24TH' => '24th St. Mission (SF)',
               'ASHB' => 'Ashby (Berkeley)',
               'BALB' => 'Balboa Park (SF)',
               'BAYF' => 'Bay Fair (San Leandro)',
               'CAST' => 'Castro Valley',
               'CIVC' => 'Civic Center/UN Plaza (SF)',
               'COLS' => 'Coliseum/Oakland Airport',
               'COLM' => 'Colma',
               'CONC' => 'Concord',
               'DALY' => 'Daly City',
               'DBRK' => 'Downtown Berkeley',
               'DUBL' => 'Dublin/Pleasanton',
               'DELN' => 'El Cerrito del Norte',
               'PLZA' => 'El Cerrito Plaza',
               'EMBR' => 'Embarcadero (SF)',
               'FRMT' => 'Fremont',
               'FTVL' => 'Fruitvale (Oakland)',
               'GLEN' => 'Glen Park (SF)',
               'HAYW' => 'Hayward',
               'LAFY' => 'Lafayette',
               'LAKE' => 'Lake Merritt (Oakland)',
               'MCAR' => 'MacArthur (Oakland)',
               'MLBR' => 'Millbrae',
               'MONT' => 'Montgomery St. (SF)',
               'NBRK' => 'North Berkeley',
               'NCON' => 'North Concord/Martinez',
               'ORIN' => 'Orinda',
               'PITT' => 'Pittsburg/Bay Point',
               'PHIL' => 'Pleasant Hill/Contra Costa Centre',
               'POWL' => 'Powell St. (SF)',
               'RICH' => 'Richmond',
               'ROCK' => 'Rockridge (Oakland)',
               'SBRN' => 'San Bruno',
               'SFIA' => "San Francisco Int'l Airport",
               'SANL' => 'San Leandro',
               'SHAY' => 'South Hayward',
               'SSAN' => 'South San Francisco',
               'UCTY' => 'Union City',
               'WCRK' => 'Walnut Creek',
               'WDUB' => 'West Dublin/Pleasanton',
               'WOAK' => 'West Oakland' } 

end
