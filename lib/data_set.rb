# coding: utf-8
LKP_SRC ||= ENV['LKP_SRC'] || File.dirname(File.dirname File.realpath $PROGRAM_NAME)

require "#{LKP_SRC}/lib/result_root.rb"
require 'csv'

class DataSet
	private

	def datum_type(datum)
		case datum
		when Array then
			case datum.first
			when String then :string_list
			else :vector
			end
		when String then :string
		else :scalar
		end
	end

	def init_fields_from_matrix(_rt, matrix)
		if not @stats
			@stats = {}
			[_rt.axes_path, matrix].each { |data|
				data.keys.each { |k|
					type = datum_type(data[k])
					next if type == :string or type == :string_list
					next if k == 'run'
					@stats[k] = type
				}
			}
		else
			@stats.select! { |k, type|
				[_rt.axes_path, matrix].any? { |data|
					data.keys.include?(k) and datum_type(data[k] == type)
				}
			}
		end
	end

	def save_csv(csvfile)
		CSV.open(csvfile, 'w+') do |csv|
			self.each { |line|
				csv << line
			}
		end
	end

	def save_stdout()
		self.each { |line|
			puts line.join(",")
		}
	end

	public

	def initialize(conditions)
		@mresult_roots = MResultRootCollection.new(conditions)
		@stats = nil
		@params = nil
		@selects = []
		@rejects = []
	end

	def init_fields()
		@mresult_roots.each { |_rt|
			init_fields_from_matrix(_rt, _rt.matrix)
		}

		@stats ||= {}
	end

	def select_fields!(&b)
		block_given? or return enum_for(__method__)

		if @stats
			@stats.select! { |k, v| yield k }
		else
			@selects << b
		end
	end

	def reject_fields!(&b)
		block_given? or return enum_for(__method__)

		if @stats
			@stats.reject! { |k, v| yield k }
		else
			@rejects << b
		end
	end

	def each(&b)
		block_given? or return enum_for(__method__)

		head_printed = false
		@mresult_roots.each { |_rt|
			matrix = _rt.matrix
			unless @stats
				# Initialization of stats is deferred till here
				init_fields_from_matrix(_rt, matrix)
				@selects.each { |b| select_fields!(&b) }
				@rejects.each { |b| reject_fields!(&b) }
			end
			unless head_printed
				headers = @stats.map { |k, type|
					k = k.gsub(',', '-')
					case type
					when :vector then ["#{k}"]
					else k
					end
				}
				yield headers.flatten
				head_printed = true
			end
			row = @stats.map { |k, type|
				begin
					v = nil
					[_rt.axes_path, matrix].each { |data| v ||= data[k] }
					outv = case type
								 when :vector then [v.average]
								 when :string_list then v.first
								 else v
								 end
					if k == 'commit' and type == :string
						tag = Git.open(project: 'linux', working_dir: GIT_WORK_TREE).gcommit(outv).interested_tag if Dir.exist?(GIT_WORK_TREE)
						outv = tag if tag
					end
					outv
				rescue NoMethodError
					0
				end
			}
			yield row.flatten
		}
	end

	def save(file, format = nil)
		format ||= file[file.rindex('.')+1 .. -1] if file.rindex('.')
		if file == '-'
			save_stdout()
		else case format
				 when 'csv' then save_csv(file)
				 else save_csv(file)  # default to csv
				 end
		end
	end

	def stats
		@stats
	end
end

def test_csv
	ds = DataSet.new('testcase' => 'hackbench')
	ds.select_fields! { |stat| stat =~ /^time\..*/ }
	ds.reject_fields! { |stat| stat =~ /\.max$/ }
	ds.save_csv('/tmp/test.csv')
	nil
end
