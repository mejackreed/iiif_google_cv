module IiifGoogleCv
  ##
  # Basic BoundingBox operations/parsing
  class BoundingBox
    attr_reader :minx, :miny, :maxx, :maxy, :scale_factor

    def initialize(minx, miny, maxx, maxy, scale_factor: 1.0)
      @minx = minx
      @miny = miny
      @maxx = maxx
      @maxy = maxy
      @scale_factor = scale_factor
    end

    def self.from_gcv_a(bounds_array, scale_factor = 1.0)
      i = new(999_999_999, 999_999_999, -999_999_999, -999_999_999, scale_factor: scale_factor)
      bounds_array.each do |vertex|
        i.check_and_set_bounds(vertex)
      end
      i
    end

    def check_and_set_bounds(vertex)
      @maxx = vertex.x / scale_factor if vertex.x / scale_factor > maxx
      @maxy = vertex.y / scale_factor if vertex.y / scale_factor > maxy
      @minx = vertex.x / scale_factor if vertex.x / scale_factor < minx
      @miny = vertex.y / scale_factor if vertex.y / scale_factor < miny
    end

    def width
      maxx - minx
    end

    def height
      maxy - miny
    end

    def to_xywh
      "#{minx.to_i},#{miny.to_i},#{width.to_i},#{height.to_i}"
    end
  end
end
