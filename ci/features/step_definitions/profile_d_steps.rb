Then(/^the environment contains the secret values as per secrets\.yml$/) do
  step "the 'env' command is run"
  expect(@output).to include('CONJUR_SINGLE_LINE_SECRET=a conjur secret on a single line')
  expect(@output).to include(<<EOL
CONJUR_MULTI_LINE_SECRET=a conjur secret
on multiple lines
EOL
  )
  expect(@output).to include('LITERAL_SECRET=a literal secret')
end

When(/^the \.profile\.d script is sourced$/) do
  @commands ||= []
  @commands << <<EOL
. #{@BUILD_DIR}/.profile.d/0000_retrieve-secrets.sh #{@BUILD_DIR}
EOL
end
