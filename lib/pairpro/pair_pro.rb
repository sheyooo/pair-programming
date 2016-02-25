require 'uri'
require 'digest'
require 'json'
require 'firebase'

module PairPro
  class PairProgram

    def initialize
      base_uri = 'https://pair-pro.firebaseio.com/'
      @firebase = Firebase::Client.new(base_uri)
    end

    def valid?(str)
      str.strip!
      if str.length > 0
        true
      else
        false
      end
    end

    def signup(username, email, password)
      response = @firebase.get("users/#{username}", shalow: true)
      password = URI.escape(Digest::SHA256.digest(password))
      if response.body.nil?
        @firebase.push("users/#{username}", { :username => username, :email => email, :password => "#{password}"})
        return true
      else
        return false
      end
    end

    def login(u, p)
      auth = false
      p = Digest::SHA256.digest(p)
      u = URI.escape(u)
      if (valid? u) && (valid? p)
        response = @firebase.get("users/#{u}")
        res = response.body.to_a[0]
        p = URI.escape(p)

        if res != nil

          if res[1].to_h["password"] == p
            auth = true
          end     
        end 
      end

      auth
    end

    def new_coding_session(id, initiator)
      response = @firebase.get("/sessions/#{id}")
      res = response.body

      if res == nil
        @firebase.push("users/#{initiator}/sessions", {session_id: id})
        true
      else
        false
      end    
    end

    def coding_session(id)

    end

    def list_sessions(username)
      response = @firebase.get("users/#{username}/sessions")
      response.body
    end

    def delete_session(id, username)
      @firebase.delete("/sessions/#{id}/")
      @firebase.delete("/users/#{username}/sessions/", {session_id: "#{id}"})
    end


  end

end