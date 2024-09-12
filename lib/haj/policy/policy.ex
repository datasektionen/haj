defmodule Haj.Policy do
  use LetMe.Policy

  object :haj do
    action :access do
      allow :spex_member
      allow role: :admin
    end

    action :admin do
      allow role: :admin
    end
  end

  object :merch do
    action :buy do
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

  object :show do
    action :export do
      allow role: :admin
    end
  end

  object :show_group do
    action :edit do
      allow :is_chef
      allow role: :admin
    end

    action :export do
      allow :is_chef
      allow role: :admin
    end
  end

  object :responsibility_comment do
    action :edit do
      allow :own_comment
      allow role: :admin
    end

    action :delete do
      allow :own_comment
      allow role: :admin
    end

    action :create do
      allow :has_responsibility
      allow role: :admin
    end
  end

  object :settings do
    action :admin do
      allow role: :admin
    end
  end

  object :applications do
    action :read do
      allow role: :admin
      allow current_group_member: :chefsgruppen
    end

    action :approve do
      allow :is_chef
      allow role: :admin
    end
  end
end
