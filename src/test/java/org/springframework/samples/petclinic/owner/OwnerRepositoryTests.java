/*
 * Copyright 2012-2025 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.springframework.samples.petclinic.owner;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.DisabledInNativeImage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.test.context.aot.DisabledInAotMode;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@DisabledInNativeImage
@DisabledInAotMode
class OwnerRepositoryTests {

	@Autowired
	private OwnerRepository owners;

	@Test
	void findByLastNameStartingWithReturnsMatchingOwners() {
		Page<Owner> page = owners.findByLastNameStartingWith("Davis", PageRequest.of(0, 10));
		assertThat(page.getContent()).isNotEmpty();
		assertThat(page.getContent().get(0).getLastName()).startsWith("Davis");
	}

	@Test
	void findByLastNameStartingWithReturnsEmptyForUnknownName() {
		Page<Owner> page = owners.findByLastNameStartingWith("ZZZ_UNKNOWN", PageRequest.of(0, 10));
		assertThat(page.getContent()).isEmpty();
	}

	@Test
	void findByIdReturnsOwner() {
		Optional<Owner> owner = owners.findById(1);
		assertThat(owner).isPresent();
		assertThat(owner.get().getFirstName()).isNotBlank();
	}

	@Test
	void findByIdReturnsEmptyForMissingId() {
		Optional<Owner> owner = owners.findById(9999);
		assertThat(owner).isEmpty();
	}

}
