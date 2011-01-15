require File.join(File.dirname(__FILE__), 'spec_helper')

describe "a Web Wiz Forum 8.0 impostor" do

  describe "authentication routines" do

    it "should be logged_in? when wwf 8.0 displays the user name" do
      config = self.config(sample_wwf80_config_params)
      auth = self.auth(config)
      page = load_fixture_page("wwf80-logged-in.html", config.app_root, 200, config.agent)

      lambda {
        auth.logged_in?(page).should be_true
      }.should_not raise_error
    end

    it "should not be logged_in? when wwf 8.0 does not display the user name" do
      config = self.config(sample_wwf80_config_params)
      auth = self.auth(config)
      page = load_fixture_page("wwf80-not-logged-in.html", config.app_root, 200, config.agent)

      lambda {
        auth.logged_in?(page).should_not be_true
      }.should_not raise_error
    end

    it "should return a page from fetch_login_page"
    it "should handle an error in fetch_login_page"

  end

end

