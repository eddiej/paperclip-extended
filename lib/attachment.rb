module Paperclip
  class Attachment
    class << self
      alias_method :original_reprocess!, :reprocess!
    end
    
     def reprocess!(*style_args)
        new_original = Tempfile.new("paperclip-reprocess")
        new_original.binmode
        if old_original = to_file(:original)
          new_original.write( old_original.respond_to?(:get) ? old_original.get : old_original.read )
          new_original.rewind

          @queued_for_write = { :original => new_original }
          instance_write(:updated_at, Time.now)
          post_process(*style_args)

          old_original.close if old_original.respond_to?(:close)
          old_original.unlink if old_original.respond_to?(:unlink)

          save
        else
          true
        end
      rescue Errno::EACCES => e
        warn "#{e} - skipping file"
        false
      end
    
  end
end
