defmodule Haj.Policy do
  use LetMe.Policy

  object :haj do
    action :access do
      allow :spex_member
    end
  end

  object :merch do
    action :buy_merch do
      allow :current_spex_member

      allow role: :admin
    end

    action :admin do
      allow current_group_member: :grafiq

      allow role: :admin
    end

    action :list_orders do
      allow current_group_member: :grafiq

      allow role: :admin
    end
  end

  object :user do
    action :edit do
      allow role: :admin
      allow :self
    end
  end

  object :responsibility do
    action :read do
      allow group_member: :chefsgruppen

      allow role: :admin
    end

    action :edit do
      allow :has_responsibility
      allow role: :admin
    end

    action :comment do
      allow :has_responsibility
      allow role: :admin
    end
  end

  object :settings do
    action :admin do
      allow role: :admin
    end
  end
end
