Sufia.config.after_create_content = lambda { |generic_file, user|
  Sufia.queue.push(ContentDepositEventJob.new(generic_file.pid, user.user_key))
}

Sufia.config.after_revert_content = lambda { |generic_file, user, revision|
  Sufia.queue.push(ContentRestoredVersionEventJob.new(generic_file.pid, user.user_key, revision))
}

Sufia.config.after_update_content = lambda { |generic_file, user|
  Sufia.queue.push(ContentNewVersionEventJob.new(generic_file.pid, user.user_key))
}

Sufia.config.after_update_metadata = lambda { |generic_file, user|
  Sufia.queue.push(ContentUpdateEventJob.new(generic_file.pid, user.user_key))
}

Sufia.config.after_destroy = lambda { |pid, user|
  Sufia.queue.push(ContentDeleteEventJob.new(pid, user.user_key))
}

