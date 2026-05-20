package org.springframework.samples.petclinic.system;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.DisabledInNativeImage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.test.context.aot.DisabledInAotMode;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Locale;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Tests locale resolution behavior: lang parameter switching, Accept-Language header
 * support, and fallback to English for unsupported locales.
 */
@WebMvcTest(WelcomeController.class)
@DisabledInNativeImage
@DisabledInAotMode
class LocaleResolutionTests {

	@Autowired
	private MockMvc mockMvc;

	@Test
	void langParameterSwitchesToGerman() throws Exception {
		mockMvc.perform(get("/").param("lang", "de"))
			.andExpect(status().isOk())
			.andExpect(content().string(containsString("Willkommen")));
	}

	@Test
	void acceptLanguageHeaderUsesSpanish() throws Exception {
		mockMvc.perform(get("/").locale(Locale.forLanguageTag("es")))
			.andExpect(status().isOk())
			.andExpect(content().string(containsString("Bienvenido")));
	}

	@Test
	void unsupportedLocaleFallsBackToEnglish() throws Exception {
		mockMvc.perform(get("/").locale(Locale.CHINESE))
			.andExpect(status().isOk())
			.andExpect(content().string(containsString("Welcome")));
	}

	@Test
	void languageSwitcherIsRendered() throws Exception {
		mockMvc.perform(get("/"))
			.andExpect(status().isOk())
			.andExpect(content().string(containsString("fa-globe")))
			.andExpect(content().string(containsString("lang=")));
	}

}
