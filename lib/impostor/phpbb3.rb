##
# phpBB3 version of the Impostor
#

class Impostor

  module Phpbb3

    ##
    # Additional configuration parameters for a Phpbb3 compatible agent:
    #
    # :posting_page
    #
    # Typical configuration parameters
    # { :type => :phpbb3,
    # :app_root => 'http://example.com/forum/',
    # :login_page => 'ucp.php?mode=login',
    # :posting_page => 'posting.php',
    # :user_agent => 'Windows IE 7',
    # :username => 'myuser',
    # :password => 'mypasswd' }

    module Auth

      ##
      # Checks if the agent is already logged by stored cookie

      def logged_in?(page)
        mm = page.search( "//a" ).detect{ | a| a.inner_html =~ /Logout \[ #{self.config.username} \]/ } ||
             page.search( "//a" ).detect{ |a| a['href'] =~ /\.\/ucp\.php\?mode=logout/ }

        not mm.nil?
      end

      ##
      # returns the login form from the login page

      def get_login_form(page)
        form = page.forms.detect { |form| form.action =~ /\/ucp\.php\?mode=login/ }
        raise Impostor::LoginError.new("unknown login page format") unless form
        form
      end

      ##
      # Sets the user name and pass word on the loing form.

      def set_username_and_password(form)
        form['username'] = username
        form['password'] = password
        form['autologin'] = 'on'
        form
      end

      ##
      # does the work of posting the login form

      def post_login(form, button)
        begin
          page = @agent.submit(form, button)
        rescue StandardError => err
          raise Impostor::LoginError.new(err)
        end
      end

    end

    module Post
      # ##
      # # Attempt to post to the forum

      # def post(forum = @forum, topic = @topic, message = @message)
      #   raise PostError.new("forum not set") unless forum
      #   raise PostError.new("topic not set") unless topic
      #   raise PostError.new("message not set") unless message

      #   login
      #   raise PostError.new("not logged in") unless @loggedin

      #   uri = posting_page
      #   uri.query = "mode=reply&f=#{forum}&t=#{topic}"

      #   # get the submit form
      #   begin
      #     page = @agent.get(uri)
      #   rescue StandardError => err
      #     raise PostError.new(err)
      #   end

      #   form = page.form('postform') rescue nil
      #   button = form.buttons.with.name('post').first rescue nil
      #   raise PostError.new("post form not found") unless button && form

      #   # set up the form and submit it
      #   form.message = message
      #   form['lastclick'] = (form['lastclick'].to_i - 60).to_s

      #   begin
      #     page = @agent.submit(form, button)
      #   rescue StandardError => err
      #     raise PostError.new(err)
      #   end

      #   # new post will be in current page uri since phpbb3 will 302 to the new
      #   # post page post anchor, e.g.
      #   # http://example.com/forum/viewtopic.php?f=37&t=52&p=3725#p3725
      #   postid = page.uri.query.split('&').detect{|a| a =~ /^p=/}.split('=').last.to_i rescue 0
      #   raise PostError.new("message did not post") unless postid > 0

      #   @forum=forum; @topic=topic; @subject=get_subject(forum,topic); @message=message

      #   true
      # end

      # ##
      # # Get the posting page for the application (specific to phpBB3)

      # def posting_page
      #   URI.join(app_root, config[:posting_page])
      # end
    end

    module Topic

      # def _new_topic_form_query(forum)
      #   uri = posting_page
      #   uri.query = "mode=newtopic&f=#{forum}"
      #   uri
      # end

      # ##
      # # make a new topic

      # def new_topic(forum=@forum, subject=@subject, message=@message)

      #   super

      #   form = page.form('postform') rescue nil
      #   raise PostError.new("post form not found") unless form
      #   button = form.buttons.detect{|b| b.name == 'post'}
      #   raise PostError.new("post form button not found") unless button

      #   # set up the form and submit it
      #   form['subject'] = subject
      #   form['message'] = message
      #   form['lastclick'] = (form['lastclick'].to_i - 60).to_s

      #   begin
      #     page = @agent.submit(form, button)
      #   rescue StandardError => err
      #     raise PostError.new(err)
      #   end

      #   # new topic will be current page uri since phpbb3 will 302 to the new
      #   # topic page, e.g.
      #   # http://example.com/forum/viewtopic.php?f=37&t=52
      #   topic = page.uri.query.split('&').detect{|a| a =~ /^t=/}.split('=').last.to_i rescue 0
      #   raise PostError.new('unexpected new topic ID') unless topic > 0

      #   # save new topic id and topic name
      #   add_subject(forum, topic, subject)
      #   @forum=forum; @topic=topic; @subject=subject; @message=message
      #   true
      # end

    end

  end
end
