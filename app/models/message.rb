class Message
  include CouchModel

  property :site_id, type: String
  property :subject, type: String
  property :name, type: String
  property :email_address, type: String
  property :phone_number, type: String
  property :delivered, type: :boolean, default: false

  auto_strip_attributes *property_names, squish: true

  property :message, type: String

  attr_accessor :do_not_fill_in
  attr_accessor :site

  set_callback :validate, :before do
    self.site_id = site.id if site
  end

  validates *property_names, no_html: true

  validates :site_id,
    presence: true

  validates :subject,
    presence: true

  validates :name,
    presence: true,
    length: {maximum: 64}

  validates :email_address,
    presence: true,
    length: {maximum: 64},
    email_format: true

  validates :phone_number,
    length: {maximum: 32}

  validates :message,
    presence: true,
    length: {maximum: 2048}

  validates :do_not_fill_in,
    length: {maximum: 0}

  validate do
    text = message.to_s.downcase

    [
      'facebook followers',
      'facebook likes',
      'facebook page likes',
      'facebook visitors',
      'search engine',
    ].each do |spam_text|
      errors.add(:message, :spam) if text.include? spam_text
    end
  end

  view :by_site_id_and_created_at,
    key: [:site_id, :created_at]

  view :by_site_id_and_id,
    key: [:site_id, :_id]

  def self.find_by_site_and_id(site, id)
    CouchPotato.database.first(by_site_id_and_id(key: [site.id, id]))
  end

  def self.find_all_by_site(site)
    CouchPotato.database.view(
      by_site_id_and_created_at(startkey: [site.id], endkey: [site.id, {}])
    ).reverse
  end

  def deliver
    MessageMailer.new_message(self).deliver
    self.delivered = true
    self.save!
  end
end
