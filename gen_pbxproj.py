import hashlib

def uid(name):
    return hashlib.md5(('Soroban_' + name).encode()).hexdigest()[:24].upper()

ids = {}
for n in ['bf_app','bf_content','bf_scene','bf_rod','bf_bead','bf_sound','bf_assets','bf_privacy','fr_app','fr_content','fr_scene','fr_rod','fr_bead','fr_sound','fr_assets','fr_info','fr_privacy','fr_product','grp_root','grp_main','grp_views','grp_spritekit','grp_services','grp_products','target','project','phase_sources','phase_frameworks','phase_resources','cfg_proj_debug','cfg_proj_release','cfg_tgt_debug','cfg_tgt_release','cfglist_proj','cfglist_tgt']:
    ids[n] = uid(n)

I = ids
content = f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 56;
	objects = {{

/* Begin PBXBuildFile section */
		{I['bf_app']} /* SorobanApp.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {I['fr_app']}; }};
		{I['bf_content']} /* ContentView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {I['fr_content']}; }};
		{I['bf_scene']} /* SorobanScene.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {I['fr_scene']}; }};
		{I['bf_rod']} /* SorobanRod.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {I['fr_rod']}; }};
		{I['bf_bead']} /* BeadNode.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {I['fr_bead']}; }};
		{I['bf_sound']} /* SoundManager.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {I['fr_sound']}; }};
		{I['bf_assets']} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {I['fr_assets']}; }};
		{I['bf_privacy']} /* PrivacyInfo.xcprivacy in Resources */ = {{isa = PBXBuildFile; fileRef = {I['fr_privacy']}; }};
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		{I['fr_app']} /* SorobanApp.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SorobanApp.swift; sourceTree = "<group>"; }};
		{I['fr_content']} /* ContentView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; }};
		{I['fr_scene']} /* SorobanScene.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SorobanScene.swift; sourceTree = "<group>"; }};
		{I['fr_rod']} /* SorobanRod.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SorobanRod.swift; sourceTree = "<group>"; }};
		{I['fr_bead']} /* BeadNode.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = BeadNode.swift; sourceTree = "<group>"; }};
		{I['fr_sound']} /* SoundManager.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SoundManager.swift; sourceTree = "<group>"; }};
		{I['fr_assets']} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};
		{I['fr_info']} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};
		{I['fr_privacy']} /* PrivacyInfo.xcprivacy */ = {{isa = PBXFileReference; lastKnownFileType = text.xml; path = PrivacyInfo.xcprivacy; sourceTree = "<group>"; }};
		{I['fr_product']} /* Soroban.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Soroban.app; sourceTree = BUILT_PRODUCTS_DIR; }};
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		{I['phase_frameworks']} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		{I['grp_root']} = {{
			isa = PBXGroup;
			children = (
				{I['grp_main']} /* Soroban */,
				{I['grp_products']} /* Products */,
			);
			sourceTree = "<group>";
		}};
		{I['grp_main']} /* Soroban */ = {{
			isa = PBXGroup;
			children = (
				{I['fr_app']} /* SorobanApp.swift */,
				{I['grp_views']} /* Views */,
				{I['grp_spritekit']} /* SpriteKit */,
				{I['grp_services']} /* Services */,
				{I['fr_assets']} /* Assets.xcassets */,
				{I['fr_info']} /* Info.plist */,
				{I['fr_privacy']} /* PrivacyInfo.xcprivacy */,
			);
			path = Soroban;
			sourceTree = "<group>";
		}};
		{I['grp_views']} /* Views */ = {{
			isa = PBXGroup;
			children = (
				{I['fr_content']} /* ContentView.swift */,
			);
			path = Views;
			sourceTree = "<group>";
		}};
		{I['grp_spritekit']} /* SpriteKit */ = {{
			isa = PBXGroup;
			children = (
				{I['fr_scene']} /* SorobanScene.swift */,
				{I['fr_rod']} /* SorobanRod.swift */,
				{I['fr_bead']} /* BeadNode.swift */,
			);
			path = SpriteKit;
			sourceTree = "<group>";
		}};
		{I['grp_services']} /* Services */ = {{
			isa = PBXGroup;
			children = (
				{I['fr_sound']} /* SoundManager.swift */,
			);
			path = Services;
			sourceTree = "<group>";
		}};
		{I['grp_products']} /* Products */ = {{
			isa = PBXGroup;
			children = (
				{I['fr_product']} /* Soroban.app */,
			);
			name = Products;
			sourceTree = "<group>";
		}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		{I['target']} /* Soroban */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {I['cfglist_tgt']};
			buildPhases = (
				{I['phase_sources']} /* Sources */,
				{I['phase_frameworks']} /* Frameworks */,
				{I['phase_resources']} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = Soroban;
			productName = Soroban;
			productReference = {I['fr_product']} /* Soroban.app */;
			productType = "com.apple.product-type.application";
		}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		{I['project']} /* Project object */ = {{
			isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1540;
				LastUpgradeCheck = 1540;
				TargetAttributes = {{
					{I['target']} = {{
						CreatedOnToolsVersion = 15.4;
					}};
				}};
			}};
			buildConfigurationList = {I['cfglist_proj']};
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				ja,
				Base,
			);
			mainGroup = {I['grp_root']};
			productRefGroup = {I['grp_products']} /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				{I['target']} /* Soroban */,
			);
		}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		{I['phase_resources']} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				{I['bf_assets']} /* Assets.xcassets in Resources */,
				{I['bf_privacy']} /* PrivacyInfo.xcprivacy in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		{I['phase_sources']} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				{I['bf_app']} /* SorobanApp.swift in Sources */,
				{I['bf_content']} /* ContentView.swift in Sources */,
				{I['bf_scene']} /* SorobanScene.swift in Sources */,
				{I['bf_rod']} /* SorobanRod.swift in Sources */,
				{I['bf_bead']} /* BeadNode.swift in Sources */,
				{I['bf_sound']} /* SoundManager.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		{I['cfg_proj_debug']} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "$(inherited) DEBUG";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			}};
			name = Debug;
		}};
		{I['cfg_proj_release']} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				VALIDATE_PRODUCT = YES;
			}};
			name = Release;
		}};
		{I['cfg_tgt_debug']} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = 83VGKGSQUH;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = Soroban/Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = "Japanese Soroban";
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.education";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.japanesesoroban.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1";
			}};
			name = Debug;
		}};
		{I['cfg_tgt_release']} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = 83VGKGSQUH;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = Soroban/Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = "Japanese Soroban";
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.education";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.japanesesoroban.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1";
			}};
			name = Release;
		}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		{I['cfglist_proj']} /* Build configuration list for PBXProject "Soroban" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{I['cfg_proj_debug']} /* Debug */,
				{I['cfg_proj_release']} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{I['cfglist_tgt']} /* Build configuration list for PBXNativeTarget "Soroban" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{I['cfg_tgt_debug']} /* Debug */,
				{I['cfg_tgt_release']} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
/* End XCConfigurationList section */
	}};
	rootObject = {I['project']} /* Project object */;
}}
"""

with open('C:/Users/Windows/Soroban/Soroban.xcodeproj/project.pbxproj', 'w', encoding='utf-8') as f:
    f.write(content)
print('pbxproj created successfully')
