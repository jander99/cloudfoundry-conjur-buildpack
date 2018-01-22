When(/^the \.profile\.d script is sourced$/) do
  @commands ||= []
  @commands << <<EOL
. #{@BUILD_DIR}/.profile.d/0000_retrieve-secrets.sh #{@BUILD_DIR}
EOL
end

Then(/^the environment contains$/) do |text|
  expect(@output).to include(text)
end
