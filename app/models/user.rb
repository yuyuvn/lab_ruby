class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword

  field :name, type: String
  field :email, type: String
  field :password_digest, type: String
  field :remember_digest, type: String
  field :admin, type: Boolean
  field :activation_digest, type: String
  field :activated, type: Boolean
  field :activated_at, type: DateTime
  field :reset_digest, type: String
  field :reset_sent_at, type: DateTime

	has_many :microposts, dependent: :destroy
  has_and_belongs_to_many :following, class_name: "User", inverse_of: :followers
  has_and_belongs_to_many :followers, class_name: "User", inverse_of: :following

	attr_accessor :remember_token, :activation_token, :reset_token

	before_save :downcase_email
	before_create :create_activation_digest
	validates :name, presence: true, length: {maximum: 50}
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum: 255 },
						format: { with: VALID_EMAIL_REGEX },
						uniqueness: { case_sensitive: false }

	has_secure_password
	validates :password, length: { minimum: 6 }, allow_blank: true

	def User.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
													  BCrypt::Engine.cost
		BCrypt::Password.create(string, cost: cost)
	end

	def User.new_token
		SecureRandom.urlsafe_base64
	end

	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end

	def authenticated?(attribute, token)
		digest = send("#{attribute}_digest")
		return false if digest.nil?
		BCrypt::Password.new(digest).is_password?(token)
	end

	def forget
		update_attribute(:remember_digest, nil)
	end

	def activate
		update_attribute(:activated,    true)
		update_attribute(:activated_at, Time.zone.now)
	end

	def send_activation_email
		UserMailer.account_activation(self).deliver!
	end

	def create_reset_digest
		self.reset_token = User.new_token
		update_attribute(:reset_digest,  User.digest(reset_token))
		update_attribute(:reset_sent_at, Time.zone.now)
	end

	def send_password_reset_email
		UserMailer.password_reset(self).deliver!
	end

	def password_reset_expired?
		reset_sent_at < 2.hours.ago
	end

	def feed
		microposts
	end

  # Follows a user.
  def follow(other_user)
    # following.create(followed_id: other_user.id)
    following << other_user
  end

  # Unfollows a user.
  def unfollow(other_user)
    # active_relationships.find_by(followed_id: other_user.id.to_s).destroy
    following.delete other_user
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

	private

	def downcase_email
      self.email = email.downcase
    end

	def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
