module Searchkick
  # can't check mapping for conversions since the new index may not be built
  module Search
    def searchkick_query(fields, term, conversions = false)
      query do
        boolean do
          must do
            dis_max do
              query do
                match fields, term, boost: 10, operator: "and", analyzer: "searchkick_search"
              end
              query do
                match fields, term, boost: 10, operator: "and", analyzer: "searchkick_search2"
              end
              query do
                match fields, term, use_dis_max: false, fuzziness: 0.7, max_expansions: 1, prefix_length: 1, operator: "and", analyzer: "searchkick_search"
              end
              query do
                match fields, term, use_dis_max: false, fuzziness: 0.7, max_expansions: 1, prefix_length: 1, operator: "and", analyzer: "searchkick_search2"
              end
            end
          end
          if conversions
            should do
              nested path: "conversions", score_mode: "total" do
                query do
                  custom_score script: "log(doc['count'].value)" do
                    match "query", term
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end