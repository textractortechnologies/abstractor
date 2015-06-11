module Abstractor
  module Methods
    module Controllers
      module AbstractorAbstractionsController
        def self.included(base)
          base.send :before_filter, :set_abstractor_abstraction, :only => [:show, :edit, :update, :clear]
        end

        def index
        end

        def show
          respond_to do |format|
            format.html { render :layout => false }
          end
        end

        def edit
          @abstractor_abstraction.clear
          respond_to do |format|
            format.html { render :layout => false }
          end
        end

        def update
          respond_to do |format|
            begin
              abstractor_suggestion = nil
              Abstractor::AbstractorAbstraction.transaction do
                abstractor_suggestion = @abstractor_abstraction.abstractor_subject.suggest(@abstractor_abstraction, nil, nil, nil, nil, nil, nil, nil, abstractor_abstraction_params[:value], abstractor_abstraction_params[:unknown].to_s.to_boolean, abstractor_abstraction_params[:not_applicable].to_s.to_boolean, nil, nil)
                abstractor_suggestion.accepted = true
                abstractor_suggestion.save!
              end

              if abstractor_suggestion
                format.html { redirect_to(abstractor_abstraction_path(@abstractor_abstraction)) }
              else
                format.json { render json: "Error processing request to create abstractor suggestions: #{e}", status: :unprocessable_entity }
              end

            rescue => e
              format.json { render json: "Error processing request to create abstractor suggestions: #{e}", status: :unprocessable_entity }
            end
          end
        end

        def clear
          respond_to do |format|
            Abstractor::AbstractorAbstraction.transaction do
              @abstractor_abstraction.value = nil
              @abstractor_abstraction.unknown = nil
              @abstractor_abstraction.not_applicable = nil
              @abstractor_abstraction.abstractor_suggestions.each do |abstractor_suggestion|
                abstractor_suggestion.accepted = nil
                abstractor_suggestion.save!
              end
              @abstractor_abstraction.save!
            end
            format.html { render "abstractor/abstractor_abstractions/show", layout: false }
          end
        end

        def update_all
          abstractor_abstraction_value = params[:abstractor_abstraction_value]
          @about = params[:about_type].constantize.find(params[:about_id])
          Abstractor::AbstractorAbstraction.update_abstractor_abstraction_other_value(@about.abstractor_abstractions, abstractor_abstraction_value)
          respond_to do |format|
            format.html { redirect_to :back }
          end
        end

        private
          def set_abstractor_abstraction
            @abstractor_abstraction = Abstractor::AbstractorAbstraction.find(params[:id])
            @about = @abstractor_abstraction.about
          end

          def abstractor_abstraction_params
            params.require(:abstractor_abstraction).permit(:id, :abstractor_subject_id, :value, :about_type, :about_id, :unknown, :not_applicable, :deleted_at, :_destroy,
            abstractor_indirect_sources_attributes: [:id, :abstractor_abstraction_id, :abstractor_abstraction_source_id, :source_type, :source_id, :source_method, :deleted_at, :_destroy]
            )
          end
      end
    end
  end
end