require 'iiif_google_cv/bounding_box'

module IiifGoogleCv
  class Annotations
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def url
      putson.url || putson.post({})
    end

    def putson
      @putson ||= Putson::Client.new
    end

    def iiif_annotations(idx)
      anno_list = IIIF::Presentation::AnnotationList.new(
        '@context' => 'http://iiif.io/api/presentation/2/context.json',
        '@id' => url
      )
      anno_list.resources = (faces_to_resources(idx) << text_to_resources(idx)).flatten.compact
      putson.put(anno_list.to_json)
      url
    end

    def text_to_resources(idx)
      client.annotations[idx].text.words.map do |word|
        xywh = IiifGoogleCv::BoundingBox.from_gcv_a(word.bounds, client.class::SCALE_FACTOR).to_xywh
        IIIF::Presentation::Resource.new(
          '@id' => SecureRandom.hex,
          '@type' => 'oa:Annotation',
          'motivation' => 'sc:painting',
          'resource' => {
            '@id' => SecureRandom.hex,
            '@type' => 'cnt:ContentAsText',
            'format' => 'text/plain',
            'chars' => word.text,
            'language' => 'eng'
          },
          'on' => "#{client.canvas_id(idx)}#xywh=#{xywh}"
        )
      end if client.annotations[idx].text?
    end

    def faces_to_resources(idx)
      client.annotations[idx].faces.map do |face|
        xywh = IiifGoogleCv::BoundingBox.from_gcv_a(face.bounds.head, client.class::SCALE_FACTOR).to_xywh
        IIIF::Presentation::Resource.new(
          '@id' => SecureRandom.hex,
          '@type' => 'oa:Annotation',
          'motivation' => 'sc:painting',
          'resource' => {
            '@id' => SecureRandom.hex,
            '@type' => 'cnt:ContentAsText',
            'format' => 'text/plain',
            'chars' => 'Face detection',
            'language' => 'eng'
          },
          'on' => "#{client.canvas_id(idx)}#xywh=#{xywh}"
        )
      end
    end
  end
end
