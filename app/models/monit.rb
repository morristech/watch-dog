module Monit
  extend self

  def reload
    system format_command('reload')
  end

  def statuses
    output = `#{format_command('summary')}`.scan(/Remote Host '.*_(\d+)'[ ]*(.*)$/)

    output.inject({}) do |coll, (site_id, status)|
      coll[site_id.to_i] = (status == "online with all services" ? "success" : "fail")
      coll
    end
  end
  
  private
  
  def format_command(command)
    "#{File.join(settings(:monit_bin_dir), 'monit')} #{settings(:monit_cli_options)} #{command}"
  end
end