module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module QueryCache
      class << self
        def included(base)
          base.class_eval do
            attr_accessor :query_cache_enabled
            alias_method_chain :columns, :query_cache
            alias_method_chain :select_all, :query_cache
          end

          dirties_query_cache base, :insert, :update, :delete
        end

        def dirties_query_cache(base, *method_names)
          method_names.each do |method_name|
            base.class_eval <<-end_code, __FILE__, __LINE__
              def #{method_name}_with_query_dirty(*args)
                clear_query_cache if @query_cache_enabled
                #{method_name}_without_query_dirty(*args)
              end

              alias_method_chain :#{method_name}, :query_dirty
            end_code
          end
        end
      end

      # Enable the query cache within the block.
      def cache
        old, @query_cache_enabled = @query_cache_enabled, true
        @query_cache ||= {}
        yield
      ensure
        clear_query_cache
        @query_cache_enabled = old
      end

      # Disable the query cache within the block.
      def uncached
        old, @query_cache_enabled = @query_cache_enabled, false
        yield
      ensure
        @query_cache_enabled = old
      end

      def clear_query_cache
        @query_cache.clear if @query_cache
      end

      def select_all_with_query_cache(*args)
        if @query_cache_enabled
          cache_sql(args.first) { select_all_without_query_cache(*args) }
        else
          select_all_without_query_cache(*args)
        end
      end

      def columns_with_query_cache(*args)
        if @query_cache_enabled
          @query_cache["SHOW FIELDS FROM #{args.first}"] ||= columns_without_query_cache(*args)
        else
          columns_without_query_cache(*args)
        end
      end

      private
        def cache_sql(sql)
          result =
            if @query_cache.has_key?(sql)
              log_info(sql, "CACHE", 0.0)
              @query_cache[sql]
            else
              @query_cache[sql] = yield
            end

          case result
          when Array
            result.collect { |row| row.dup }
          when nil, Fixnum, Float, true, false
            result
          else
            result.dup
          end
        rescue TypeError
          result
        end
    end
  end
end
