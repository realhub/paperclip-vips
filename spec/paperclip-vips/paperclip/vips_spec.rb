RSpec.describe PaperclipVips do
  it "has a version number" do
    expect(PaperclipVips::VERSION).not_to be nil
  end

  describe "crop" do
    before(:each) do
      path = File.join(PaperclipVips.root, 'spec', 'support', 'image.jpg')
      @file = File.new(path, 'rb')
    end
  
    after(:each) do
      @file.close
    end

    it "returns nil as default" do
      service = Paperclip::Vips.new(@file, { geometry: "400x400" })
      result = service.send(:crop)
      expect(result).to eq(nil)
    end

    it "returns centre if should_crop is true" do
      service = Paperclip::Vips.new(@file, { geometry: "400x400#" })
      result = service.send(:crop)
      expect(result).to eq(:centre)
    end

    it "returns crop value if supplied in options" do
      service = Paperclip::Vips.new(@file, { geometry: "400x400#", crop: :low })
      result = service.send(:crop)
      expect(result).to eq(:low)
    end
  end

  describe "current_format" do
    it "returns format if path includes extension" do
      file = Tempfile.new(['test', '.jpg'])
      File.write(file.path, File.read(File.join(PaperclipVips.root, 'spec', 'support', 'image.jpg')))

      service = Paperclip::Vips.new(file, { geometry: "400x400" })
      result = service.send(:current_format, file)
      expect(result).to eq(".jpg")

      file.close
    end

    it "returns format if path excludes extension" do
      string_io = StringIO.open(File.read(File.join(PaperclipVips.root, 'spec', 'support', 'image.jpg')))
      file = Paperclip.io_adapters.for(string_io)
      file.original_filename = "text.gif"

      service = Paperclip::Vips.new(file, { geometry: "1200x800" })
      result = service.send(:current_format, file)
      expect(result).to eq(".gif")

      file.close
    end
  end

  describe "jpeg images" do
    before(:each) do
      path = File.join(PaperclipVips.root, 'spec', 'support', 'image.jpg')
      @file = File.new(path, 'rb')
    end

    after(:each) do
      @file.close
    end

    it "processes them correctly" do
      service = Paperclip::Vips.new(@file, { geometry: "600x400" })
      result = service.make
      
      new_image = Vips::Image.new_from_file(result.path)
      expect(new_image.width).to eq(600)
      expect(new_image.height).to eq(337)
    end

    it "crops them correctly" do
      service = Paperclip::Vips.new(@file, { geometry: "600x400#" })
      result = service.make
      
      new_image = Vips::Image.new_from_file(result.path)
      expect(new_image.width).to eq(600)
      expect(new_image.height).to eq(400)
    end
  end

  describe "gif images" do
    before(:each) do
      path = File.join(PaperclipVips.root, 'spec', 'support', 'image.gif')
      @file = File.new(path, 'rb')
    end

    after(:each) do
      @file.close
    end

    it "processes them correctly" do
      service = Paperclip::Vips.new(@file, { geometry: "300x200" })
      result = service.make
      
      new_image = Vips::Image.new_from_file(result.path)
      expect(new_image.width).to eq(300)
      expect(new_image.height).to eq(225)
    end

    it "crops them correctly" do
      service = Paperclip::Vips.new(@file, { geometry: "200x200#" })
      result = service.make
      
      new_image = Vips::Image.new_from_file(result.path)
      expect(new_image.width).to eq(200)
      expect(new_image.height).to eq(200)
    end
  end

  describe "png images" do
    before(:each) do
      path = File.join(PaperclipVips.root, 'spec', 'support', 'image.png')
      @file = File.new(path, 'rb')
    end

    after(:each) do
      @file.close
    end

    it "processes them correctly" do
      service = Paperclip::Vips.new(@file, { geometry: "300x200" })
      result = service.make
      
      new_image = Vips::Image.new_from_file(result.path)
      expect(new_image.width).to eq(300)
      expect(new_image.height).to eq(225)
    end

    it "crops them correctly" do
      service = Paperclip::Vips.new(@file, { geometry: "200x200#" })
      result = service.make
      
      new_image = Vips::Image.new_from_file(result.path)
      expect(new_image.width).to eq(200)
      expect(new_image.height).to eq(200)
    end
  end
end
