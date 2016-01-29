# coding: utf-8
LKP_SRC ||= ENV['LKP_SRC'] || File.dirname(File.dirname File.realpath $PROGRAM_NAME)

require "#{LKP_SRC}/lib/yaml.rb"

class Analyzer
	private

	def parse_command(command, defaults, parameters)
		values = {}
		defaults.each { |param, default|
			values[param] = default
		}
		parameters.each { |param, value|
			values[param] = value
		}
		to_evaluate = command.gsub(/#\{([\w]+)\}/, '#{values[\'\1\']}').gsub('"', '\"')
		eval("\"#{to_evaluate}\"")
	end

	public

	def initialize(algorithm, parameters)
		alinfo = $algorithms[algorithm]
		return unless alinfo

		defaults = alinfo['parameters'].to_a.map { |param, paraminfo|
			[param, paraminfo['default']]
		}.to_h
		@command = parse_command(alinfo['command'], defaults, parameters)
		@subcommand = parse_command(alinfo['subcommand'], defaults, parameters)
	end

	def run(datafile)
		if @command and @subcommand
			system "#{LKP_SRC}/analyzers/#{@command} #{datafile} '#{@subcommand}'"
		end
	end
end

class << Analyzer
	def algorithms
		@algorithms if @algorithms

		@algorithms = {}
		yaml = load_yaml("#{LKP_SRC}/etc/analysis-algorithms.yaml").freeze
		yaml.each { |toolbox, tbinfo|
			command = tbinfo['command']
			tbinfo['algorithms'].each { |algorithm, alinfo|
				@algorithms[algorithm] = {
					'description' => alinfo['description'],
					'command' => tbinfo['command'],
					'subcommand' => alinfo['subcommand'],
					'parameters' => alinfo['parameters']
				}
			} if tbinfo['algorithms']
		} if yaml

		@algorithms
	end
end
