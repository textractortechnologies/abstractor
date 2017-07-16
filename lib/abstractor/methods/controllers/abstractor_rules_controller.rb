module Abstractor
  module Methods
    module Controllers
      module AbstractorRulesController
        def self.included(base)
          base.send :helper, :all
          base.send :before_filter, :set_abstractor_rule,     except: [:index, :new, :create]
        end

        def index
          abstractor_rules = Abstractor::AbstractorRule.not_deleted.search_across_fields(params[:search]).order(id: :asc)
          if params[:abstractor_subject_ids]
            abstractor_subject_ids = params[:abstractor_subject_ids].map(&:to_i)
            abstractor_rules = abstractor_rules.search_by_abstractor_subjects_ids(abstractor_subject_ids)
          end
          @abstractor_rules = abstractor_rules.paginate(per_page: 10, page: params[:page])
          respond_to do |format|
            format.json { render json: Abstractor::Serializers::AbstractorRulesSerializer.new(abstractor_rules).as_json }
            format.html
          end
        end

        def new
          @abstractor_rule = Abstractor::AbstractorRule.new
        end

        def create
          @abstractor_rule = Abstractor::AbstractorRule.new(abstractor_rule_params)
          if @abstractor_rule.save
            redirect_to action: :index
          else
            render :new
          end
        end

        def show
        end

        def edit
        end

        def update
          if @abstractor_rule.update_attributes(abstractor_rule_params)
            redirect_to action: :index
          else
            render :edit
          end
        end

        def destroy
          @abstractor_rule.soft_delete!
          redirect_to action: :index
        end

        private
          def set_abstractor_rule
            @abstractor_rule = Abstractor::AbstractorRule.find(params[:id])
          end

          def abstractor_rule_params
            params.require(:abstractor_rule).permit(
              :name,
              :rule,
              abstractor_subjects_not_deleted_ids: []
            )
          end
      end
    end
  end
end