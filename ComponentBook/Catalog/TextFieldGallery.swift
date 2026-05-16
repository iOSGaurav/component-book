import SwiftUI

/// Catalog screen demoing every ``CBTextField`` configuration variant.
struct TextFieldGallery: View {

    @State private var basic = ""
    @State private var email = ""
    @State private var password = ""
    @State private var search = ""
    @State private var username = "alice"
    @State private var invalidEmail = "not-an-email"
    @State private var bio = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                variantsSection
                stylesSection
                sizesSection
                validationSection
                decorationSection
                statesSection
            }
            .padding(20)
        }
        .navigationTitle("Text field")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var variantsSection: some View {
        section("Variants") {
            CBTextField("Name", placeholder: "Your full name", text: $basic)
            CBTextField(
                "Password",
                placeholder: "At least 8 characters",
                text: $password,
                configuration: .init(variant: .secure, leadingIcon: "lock")
            )
            .textContentType(.newPassword)
        }
    }

    private var stylesSection: some View {
        section("Styles") {
            CBTextField("Outlined", placeholder: "Standard outlined", text: $basic)
            CBTextField(
                "Filled",
                placeholder: "Tinted background",
                text: $basic,
                configuration: .init(style: .filled)
            )
            CBTextField(
                "Underlined",
                placeholder: "Bottom border only",
                text: $basic,
                configuration: .init(style: .underlined)
            )
        }
    }

    private var sizesSection: some View {
        section("Sizes") {
            CBTextField(
                "Small",
                placeholder: "Dense / inline",
                text: $basic,
                configuration: .init(size: .small)
            )
            CBTextField(
                "Medium",
                placeholder: "Default — meets 44pt minimum",
                text: $basic,
                configuration: .init(size: .medium)
            )
            CBTextField(
                "Large",
                placeholder: "Prominent",
                text: $basic,
                configuration: .init(size: .large)
            )
        }
    }

    private var validationSection: some View {
        section("Validation") {
            CBTextField(
                "Username",
                placeholder: "Choose a username",
                text: $username,
                configuration: .init(validationState: .success, helperText: "Available")
            )
            CBTextField(
                "Email",
                placeholder: "you@example.com",
                text: $invalidEmail,
                configuration: .init(validationState: .error, helperText: "Enter a valid email")
            )
            CBTextField(
                "Phone",
                placeholder: "Optional",
                text: $basic,
                configuration: .init(helperText: "We only call in an emergency")
            )
        }
    }

    private var decorationSection: some View {
        section("Icons & clear button") {
            CBTextField(
                "Search",
                placeholder: "Search the catalog",
                text: $search,
                configuration: .init(
                    style: .filled,
                    leadingIcon: "magnifyingglass",
                    showsClearButton: true
                )
            )
            .submitLabel(.search)

            CBTextField(
                "Email",
                placeholder: "you@example.com",
                text: $email,
                configuration: .init(leadingIcon: "envelope")
            )
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            CBTextField(
                "Bio",
                placeholder: "Tell us about yourself",
                text: $bio,
                configuration: .init(style: .underlined, trailingIcon: "person.fill")
            )
        }
    }

    private var statesSection: some View {
        section("Disabled") {
            CBTextField(
                "Read only",
                placeholder: "Cannot edit",
                text: .constant("locked value"),
                configuration: .init(leadingIcon: "lock.fill")
            )
            .disabled(true)
        }
    }

    @ViewBuilder
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            VStack(alignment: .leading, spacing: 16) {
                content()
            }
        }
    }
}

#Preview {
    NavigationStack {
        TextFieldGallery()
    }
}
