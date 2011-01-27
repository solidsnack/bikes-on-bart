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
    def query_xml(params)
      url = self.query_string(params)
      Net::HTTP.get(URI.parse(url))
    end
    def query(params)
      xml = self.query_xml(params)
      Nokogiri::XML(xml)
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

  def hash2get(hash)
    # Use URL escaping some day.
    hash.inject("") do |acc, pair|
      k, v = pair
      acc.empty? ? "?#{k}=#{v}" : "#{acc}&#{k}=#{v}"
    end
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
