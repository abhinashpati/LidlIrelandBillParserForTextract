# LidlIrelandBillParserForTextract

Welcome to my new gem!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'LidlIrelandBillParserForTextract'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install LidlIrelandBillParserForTextract

## Usage

### What It Does:

Parses the json data of the Lidl Ireland Stores generated by AWS Textract.

```ruby
LidlIrelandBillParserForTextract.parseData(PATH_TO_JSON_FILE)
```

The Json file must be a valid Textract Output of a Lidl Store Ireland Receipt.
It Parses the Raw LINE Block Data of Textract results and generated a StoreData Model as output.

### Input=> 
	Json File of the receipt data from textract.

### OutPut => 
				
	StoreData Model.

### StoreData Model Atributes => 
```ruby
	ProductName :string,
	ProductQuantity :integer,
	UnitPrice :float,
	Discount :float,
	TotalPrice :float
```
### Example
```ruby
#/app/controllers/home_controler.rb
def index
@results  = LidlIrelandBillParserForTextract.parseData(File.join Rails.root, "/lib/TextractOutput.json"))
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/abhinashpati/LidlIrelandBillParserForTextract. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the LidlIrelandBillParserForTextract project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/abhinashpati/LidlIrelandBillParserForTextract/blob/master/CODE_OF_CONDUCT.md).
