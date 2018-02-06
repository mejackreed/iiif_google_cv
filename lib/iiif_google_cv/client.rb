require 'faraday'
require 'iiif/presentation'
require 'google/cloud/vision'
require 'putson'

require 'iiif_google_cv/annotations'

module IiifGoogleCv
  class Client
    SCALE_FACTOR = (ENV['SCALE_FACTOR'] || 0.5).to_f
    attr_reader :manifest, :manifest_url

    def initialize(manifest_url: nil, manifest: nil)
      unless manifest_url || manifest
        raise(
          ArgumentError,
          'manifest_url or manifest must be provided'
        )
      end
      @manifest_url = manifest_url
      @manifest = manifest
    end

    def putson
      @putson ||= Putson::Client.new
    end

    def url
      putson.url || putson.post({})
    end

    def vision
      @vision ||= Google::Cloud::Vision.new
    end

    def annotations
      puts "Annotating #{image_resources}"
      @annotations ||= [*vision.annotate(
        *image_resources,
        faces: true,
        labels: true,
        landmarks: true,
        logos: true,
        text: true
      )]
    end

    def process
      annotations
    end

    def image_resources
      iiif_manifest.sequences.collect do |s|
        s.canvases.collect do |c|
          c.images.collect do |i|
            i.resource['@id'].gsub('full/0', "pct:#{(SCALE_FACTOR * 100).to_i}/0")
          end
        end
      end.flatten.compact
    end

    def canvas_id(idx)
      iiif_manifest.sequences.map do |s|
        s.canvases[idx]['@id']
      end.flatten.compact.first
    end

    def iiif_manifest
      @iiif_manifest ||= IIIF::Service.parse(manifest_body)
    end

    ##
    def iiif_manifest_with_annotations
      @iiif_manifest_with_annotations ||= iiif_manifest.clone
      @iiif_manifest_with_annotations['@id'] = url
      @iiif_manifest_with_annotations.sequences.map do |s|
        s.canvases.map.with_index do |c, i|
          c.other_content = [
            {
              '@id' => iiif_annotations(i),
              '@type' => 'sc:AnnotationList'
            }
          ]
        end
      end
      putson.put(@iiif_manifest_with_annotations)
    end

    def iiif_annotations(i)
      IiifGoogleCv::Annotations.new(self).iiif_annotations(i)
    end

    def manifest_body
      return manifest if manifest
      @manifest = Faraday.get(manifest_url).body
      @manifest
    end
  end
end
