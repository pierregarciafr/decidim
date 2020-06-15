# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: budget_component.organization }
  let(:context) do
    {
      current_component: budget_component,
      project: project
    }
  end
  let(:budget_component) { create :budget_component }
  let(:project) { create :project, component: budget_component }
  let(:permission_action) { Decidim::PermissionAction.new(action) }

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :vote, subject: :project }
    end

    it_behaves_like "delegates permissions to", Decidim::Budgets::Admin::Permissions
  end

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :project }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a project nor an order" do
    let(:action) do
      { scope: :public, action: :vote, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when action is a random one" do
    let(:action) do
      { scope: :public, action: :foobar, subject: :project }
    end

    it_behaves_like "permission is not set"
  end

  context "when reporting a project" do
    let(:action) do
      { scope: :public, action: :report, subject: :project }
    end

    it { is_expected.to eq true }
  end

  context "when voting a project" do
    let(:action) do
      { scope: :public, action: :vote, subject: :project }
    end

    it { is_expected.to eq true }
  end

  context "when subject is an order" do
    let(:action) do
      { scope: :public, action: :create, subject: :order }
    end

    it { is_expected.to eq true }
  end

  context "when component has a parent component" do
    let(:parent_component) { create :budgets_group_component, :with_children }
    let(:budget_component) { parent_component.children.first }
    let(:context) do
      {
        current_component: budget_component,
        project: project,
        parent_component_context: {
          workflow_instance: double.tap do |mock|
                               allow(mock).to receive(:vote_allowed?).and_return(false)
                             end
        }
      }
    end

    context "when voting a project" do
      let(:action) do
        { scope: :public, action: :vote, subject: :project }
      end

      it { is_expected.to eq false }
    end

    context "when creating an order" do
      let(:action) do
        { scope: :public, action: :create, subject: :order }
      end

      it { is_expected.to eq false }
    end
  end
end
