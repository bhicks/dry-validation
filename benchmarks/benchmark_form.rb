require 'benchmark/ips'
require 'active_model'

require 'dry-validation'

I18n.locale = :en
I18n.backend.load_translations

class User
  include ActiveModel::Validations

  attr_reader :email, :age

  validates :email, :age, presence: true
  validates :age, numericality: { greater_than: 18 }

  def initialize(attrs)
    @email, @age = attrs.values_at('email', 'age')
  end
end

schema = Dry::Validation.Schema do
  configure do
    config.messages = :i18n
    config.type_specs = true
  end

  required(:email, :string).filled
  required(:age, :int).filled(:int?, gt?: 18)
end

form = Dry::Validation.Form do
  configure do
    config.messages = :i18n
    config.type_specs = true
  end

  required(:email, :string).filled
  required(:age, :int).filled(:int?, gt?: 18)
end

params = { 'email' => '', 'age' => '18' }

Benchmark.ips do |x|
  x.report('ActiveModel::Validations') do
    user = User.new(params)
    user.validate
    user.errors
  end

  x.report('dry-validation / schema') do
    schema.(params).messages
  end

  x.report('dry-validation / form') do
    form.(params).messages
  end

  x.compare!
end
