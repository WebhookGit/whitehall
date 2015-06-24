module OrganisationHelper
  def find_or_create_organisation(name)
    Organisation.find_by(name: name) || create(:organisation, name: name)
  end

  def fill_in_organisation_translation_form(translation)
    translation = translation.stringify_keys

    fill_in "Name", with: translation["name"]
    fill_in "Acronym", with: translation["acronym"]
    fill_in "Logo formatted name", with: translation["logo formatted name"]
    click_on "Save"
  end

  def feature_policies_on_organisation(policies)
    click_link "Featured policies"
    policies.each do |policy|
      click_button "Feature #{policy}"
    end
  end

  def unfeature_organisation_policy(policy)
    click_link "Featured policies"
    click_link "Unfeature #{policy}"
  end

end

World(OrganisationHelper)
