module Paperclip
  module Storage
    module S3    
  
      def flush_writes 
        puts "Called Flush Writes"
        puts @queued_for_write.to_s
   
        ## This is the only change to the Paperlcip core code - the original file is never written to S3 from Heroku as that is where it originated.
        ## Worth pointing out the private function is redeclared below also.
        if self.instance.instance_of?(Photo) 
          @queued_for_write.delete(:original) 
        end    
        ## EJ.        
              
        @queued_for_write.each do |style, file|
         begin
           puts("Extended -- : saving #{path(style)}")
           # log("Extended: saving #{path(style)}")
           AWS::S3::S3Object.store(path(style),
                                   file,
                                   bucket_name,
                                   {:content_type => file.content_type.to_s.strip,
                                    :access => (@s3_permissions[style] || @s3_permissions[:default]),
                                   }.merge(@s3_headers))
         rescue AWS::S3::NoSuchBucket => e
           create_bucket
           retry
         rescue AWS::S3::ResponseError => e
           raise
         end
        end
        after_flush_writes 
        @queued_for_write = {}
        end
       
       
       private
       
       # This is a private function in the original Attachment class so it needs to be defined in this class also. (it is exactly the same)
       def after_flush_writes
         @queued_for_write.each do |style, file|
           file.close unless file.closed?
           file.unlink if file.respond_to?(:unlink) && file.path.present? && File.exist?(file.path)
         end
       end
       
      
    end
  end
end


