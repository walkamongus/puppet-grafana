Puppet::Type.newtype(:grafana_notification) do
  @doc = 'Create a new Grafana alert notification'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The name of the new Grafana alert notification.'
  end

  newproperty(:type) do
    desc 'The type of alert notification to create'
    newvalues(:email, :slack, :pagerduty)
    defaultto :email
  end

  newproperty(:is_default, :boolean => true) do
    desc 'Whether to use the notification as the default notification'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:settings) do
    desc 'A hash of settings for the alert notification'
  end
end
