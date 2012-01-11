require 'lib/generic_scope'

module Jacky
  class RepositoryScope < GenericScope

    VCS_TYPES = ["mercurial", "git", "subversion"]

    def on_help
      puts "Available repository scope commands:"
      puts "  #{$0} repository create name type \"nice title\""
    end

    def on_create
      command, name, type, title, create_structure = *@argv
      if @argv.size < 3
        die_with_msg "not enough arguments."
      end
      title = name unless title
      unless VCS_TYPES.include?(type)
        die_with_msg "repository type can be only: #{VCS_TYPES.join(", ")}"
      end

      res = Beanstalk::API::Repository.create(
        "name" => name,
        "title" => title,
        "type_id" => type)
      if res.id
        STDERR.puts "Successfully created #{name} repository with ID #{res.id}"
        STDERR.puts "You can find it using following URL: "
        STDERR.puts res.repository_url
      else
        STDERR.puts "Failed to create repository due to following errors:\n\n"
        for error in res.errors.full_messages
          STDERR.puts "* #{error}"
        end
        die!
      end
    end

    def on_url
      command, name = *@argv
      die_with_msg "please provide the name of the repository to lookup" unless name
      repository = find_repository_by_name(name)
      if repository
        puts repository.repository_url
      else
        die_with_msg "repository not found"
      end
    end

    # def on_delete
    #   command, name = *@argv
    #   repository = find_repository_by_name(name)
    #   output "Are you sure you want to delete \"#{name}\" repository from \"#{Jacky::Boot.instance.config.domain}\" account?"
    #   STDERR.print "yes or no, default is no: "
    #   if STDIN.gets.strip == "yes"
    #     repository.destroy
    #   else
    #     output "Delete canceled."
    #   end
    # end

    def find_repository_by_name(name)
      Beanstalk::API::Repository.find(:all).find { |rep| rep.name == name }
    end
  end
end
