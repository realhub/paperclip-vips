module Paperclip
  class Vips < Processor
    attr_accessor :current_geometry, :target_geometry, :format, :whiny, :convert_options,
                  :source_file_options, :auto_orient

    def initialize(file, options = {}, attachment = nil)
      super

      geometry = options[:geometry].to_s
      @should_crop = geometry[-1,1] == '#'
      @target_geometry = options.fetch(:string_geometry_parser, Geometry).parse(geometry)
      @current_geometry = options.fetch(:file_geometry_parser, Geometry).from_file(@file)
      @whiny = options.fetch(:whiny, true)
      
      @current_format = current_format(file).downcase
      @format = options[:format] || @current_format

      @basename = File.basename(@file.path, @current_format)
    end

    def make
      source = @file
      filename = [@basename, @format ? ".#{@format}" : ""].join
      destination = TempfileFactory.new.generate(filename)

      begin
        thumbnail = ::Vips::Image.thumbnail(source.path, width, { height: crop ? height : nil, crop: crop }) if @target_geometry
        thumbnail = ::Vips::Image.new_from_file(source.path) if !defined?(thumbnail) || thumbnail.nil?
        thumbnail = process_convert_options(thumbnail)
        save_thumbnail(thumbnail, destination.path)
        
      rescue => e
        if @whiny
          message = "There was an error processing the thumbnail for #{@basename}:\n" + e.message
          raise Paperclip::Error, message
        end
      end

      return destination
    end

    private
      def crop
        if @should_crop
          return @options[:crop] || :centre
        end

        nil
      end

      def current_format(file)
        extension = File.extname(file.path)
        return extension if extension.present?

        extension = File.extname(file.original_filename)
        return extension if extension.present?

        return ""
      end

      def width
        @target_geometry&.width || @current_geometry.width
      end

      def height
        @target_geometry&.height || @current_geometry.height
      end
      
      def process_convert_options(image)
        if image && @options[:convert_options].present?
          commands = JSON.parse(@options[:convert_options], symbolize_names: true)
          commands.each do |cmd|
            image = ::Vips::Operation.call(cmd[:cmd], [image, *cmd[:args]], cmd[:optional] || {})
          end
        end

        return image
      end

      def save_thumbnail(thumbnail, path)
        case @current_format
        when ".jpeg", ".jpg"
          save_jpg(thumbnail, path)
        when ".gif"
          save_gif(thumbnail, path)
        when ".png"
          save_png(thumbnail, path)
        end
      end

      def save_jpg(thumbnail, path)
        thumbnail.jpegsave(path)
      end

      def save_gif(thumbnail, path)
        thumbnail.magicksave(path)
      end

      def save_png(thumbnail, path)
        thumbnail.pngsave(path)
      end
  end
end
