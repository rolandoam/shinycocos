# got to also check this... :-S

require 'menu_scene'

class TestTwitter < MenuScene
  include Cocos2D
  
  def initialize
    @tf = TextField.new([200, 100, 150, 31], true)
    @tf.delegate = self
    @tf.attach
    # Director.add_touch_handler(self)
    # puts "test_user: #{UserDefaults["test_user"].inspect}"
    super
  end
  
  def on_exit
    # @tf.detach
  end

  def text_field_action(text_field)
    text_field.resign_first_responder # close the keyboard
    puts "text: #{text_field.value}"
    # UserDefaults["test_user"] = text_field.value
    # if UserDefaults.synchronize
    #   puts "data saved"
    # end
    true
  end
  
  def touch_began(touch)
    puts "testing twitter module (touch: #{touch.inspect})"
    if err = Twitter.verify_credentials("funkaster", "i would like to share my pass with you")
      ns_log "twitt response: #{err}"
      # err == 200 means everything was ok!
      # you should store the user and pass in order to not
      # verify each time if the user/pass pair is correct
      if err == 200
        err = Twitter.twitt("funkaster", "you gotta be kidding me", "I scored 10000 points on my new iPhone game!")
        if err && err == 200
          ns_log "twitt ok!"
        else
          ns_log "ooops... something went wrong!: #{err.inspect}"
        end
      end
    else
      ns_log "connection error"
    end
  end
end
