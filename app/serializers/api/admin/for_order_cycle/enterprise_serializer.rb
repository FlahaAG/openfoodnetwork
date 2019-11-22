require 'open_food_network/enterprise_issue_validator'

class Api::Admin::ForOrderCycle::EnterpriseSerializer < ActiveModel::Serializer
  attributes :id, :name, :managed,
             :issues_summary_supplier, :issues_summary_distributor,
             :is_primary_producer, :is_distributor, :sells

  def issues_summary_supplier
    issues =
      OpenFoodNetwork::EnterpriseIssueValidator.
        new(object).
        issues_summary(confirmation_only: true)

    if issues.nil? && products.empty?
      issues = "no products in inventory"
    end
    issues
  end

  def issues_summary_distributor
    OpenFoodNetwork::EnterpriseIssueValidator.new(object).issues_summary
  end

  def managed
    Enterprise.managed_by(options[:spree_current_user]).include? object
  end

  private

  def products_scope
    if order_cycle.prefers_product_selection_from_coordinator_inventory_only?
      object.supplied_products.visible_for(order_cycle.coordinator)
    else
      object.supplied_products
    end
  end

  def products
    @products ||= products_scope
  end

  def order_cycle
    options[:order_cycle]
  end
end
