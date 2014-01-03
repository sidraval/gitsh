require 'spec_helper'
require 'gitsh/prompter'

describe Gitsh::Prompter do
  include Color

  describe '#prompt' do
    context 'an un-initialized git repository' do
      it 'displays an uninitialized prompt' do
        env = env_double(repo_initialized?: false)
        prompter = Gitsh::Prompter.new(env: env)

        expect(prompter.prompt).to eq(
          "#{cyan}#{cwd_basename}#{clear} " \
          "#{blue}uninitialized#{clear}" \
          "#{red_background}!!#{clear} "
        )
      end
    end

    context 'a clean repository' do
      it 'displays the branch name and a clean symbol' do
        env = env_double(repo_current_head: 'my-feature')
        prompter = Gitsh::Prompter.new(env: env)

        expect(prompter.prompt).to eq(
          "#{cyan}#{cwd_basename}#{clear} " \
          "#{blue}my-feature#{clear}" \
          "@ "
        )
      end
    end

    context 'a repository with untracked files' do
      it 'displays the branch name and an untracked symbol' do
        env = env_double(repo_has_untracked_files?: true)
        prompter = Gitsh::Prompter.new(env: env)

        expect(prompter.prompt).to eq(
          "#{cyan}#{cwd_basename}#{clear} " \
          "#{blue}master#{clear}" \
          "#{red}!#{clear} "
        )
      end
    end

    context 'a repository with uncommitted changes' do
      it 'displays the branch name an a modified symbol' do
        env = env_double(repo_has_modified_files?: true)
        prompter = Gitsh::Prompter.new(env: env)

        expect(prompter.prompt).to eq(
          "#{cyan}#{cwd_basename}#{clear} " \
          "#{blue}master#{clear}" \
          "#{orange}&#{clear} "
        )
      end
    end

    context 'with color disabled' do
      it 'displays the prompt without colors' do
        env = env_double(repo_has_modified_files?: true)
        prompter = Gitsh::Prompter.new(color: false, env: env)

        expect(prompter.prompt).to eq "#{cwd_basename} master& "
      end
    end

    context 'with a custom prompt format' do
      it 'replaced %# with the prompt terminator' do
        env = env_double(repo_has_modified_files?: true, format: '%#')
        prompter = Gitsh::Prompter.new(env: env)

        expect(prompter.prompt).to eq "#{orange}&#{clear} "
      end

      it 'replaces %b with the current HEAD name' do
        env = env_double(repo_current_head: 'a-branch', format: '%b')
        prompter = Gitsh::Prompter.new(env: env)

        expect(prompter.prompt).to eq "#{blue}a-branch#{clear} "
      end

      it 'replaces %d with the absolute path of the current directory' do
        env = env_double(format: '%d')
        prompter = Gitsh::Prompter.new(env: env)

        expect(prompter.prompt).to eq "#{cyan}#{Dir.getwd}#{clear} "
      end

      it 'replaces %D with the basename of the current directory' do
        env = env_double(format: '%D')
        prompter = Gitsh::Prompter.new(env: env)

        expect(prompter.prompt).to eq "#{cyan}#{File.basename(Dir.getwd)}#{clear} "
      end
    end

    def env_double(attrs={})
      format = attrs.delete(:format)
      default_attrs = {
        repo_initialized?: true,
        repo_has_modified_files?: false,
        repo_has_untracked_files?: false,
        repo_current_head: 'master'
      }
      stub('Environment', default_attrs.merge(attrs)) do |env|
        env.stubs(:[]).with('gitsh.prompt').returns(format)
      end
    end
  end
end
