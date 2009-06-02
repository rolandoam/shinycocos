require 'menu_scene'

class TestTwitter < MenuScene
  include Cocos2D
  
  def initialize
    enable_touch(true)
    super
    Director.add_text_field [200, 100, 150, 31], true, self
    puts "test_user: #{UserDefaults["test_user"].inspect}"
  end

  def text_field_action(text)
    # return true to close the keyboard (text field will resign its first reponder status)
    puts "text: #{text}"
    UserDefaults["test_user"] = text
    if UserDefaults.synchronize
      puts "data saved"
    end
    true
  end
  
  def touches_began(touches)
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
