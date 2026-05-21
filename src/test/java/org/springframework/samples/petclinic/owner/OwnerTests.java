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

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * Unit tests for {@link Owner}.
 */
class OwnerTests {

	private Owner createOwnerWithPet(String petName, Integer petId) {
		Owner owner = new Owner();
		Pet pet = new Pet();
		pet.setName(petName);
		owner.addPet(pet);
		if (petId != null) {
			pet.setId(petId);
		}
		return owner;
	}

	@Test
	void getPetByIdReturnsNullForNewPet() {
		Owner owner = createOwnerWithPet("Fido", null);
		assertThat(owner.getPet(99)).isNull();
	}

	@Test
	void getPetByIdReturnsMatchingPet() {
		Owner owner = createOwnerWithPet("Buddy", 7);
		Pet found = owner.getPet(7);
		assertThat(found).isNotNull();
		assertThat(found.getName()).isEqualTo("Buddy");
	}

	@Test
	void getPetByIdReturnsNullForNonMatchingId() {
		Owner owner = createOwnerWithPet("Rex", 5);
		assertThat(owner.getPet(999)).isNull();
	}

	@Test
	void getPetByNameIgnoreNewFiltersNewPets() {
		Owner owner = createOwnerWithPet("Lucky", null);
		assertThat(owner.getPet("Lucky", true)).isNull();
		assertThat(owner.getPet("Lucky", false)).isNotNull();
	}

	@Test
	void getPetByNameReturnsNullForNonexistent() {
		Owner owner = new Owner();
		assertThat(owner.getPet("Ghost")).isNull();
	}

	@Test
	void getPetByNameIsCaseInsensitive() {
		Owner owner = createOwnerWithPet("Buddy", null);
		assertThat(owner.getPet("buddy")).isNotNull();
		assertThat(owner.getPet("BUDDY")).isNotNull();
	}

	@Test
	void addPetDoesNotAddExistingPet() {
		Owner owner = new Owner();
		Pet pet = new Pet();
		pet.setId(5);
		pet.setName("Rex");
		owner.addPet(pet);
		assertThat(owner.getPets()).isEmpty();
	}

	@Test
	void toStringContainsOwnerFields() {
		Owner owner = new Owner();
		owner.setFirstName("John");
		owner.setLastName("Doe");
		owner.setAddress("123 Main St");
		owner.setCity("Springfield");
		owner.setTelephone("5551234567");
		String result = owner.toString();
		assertThat(result).contains("lastName", "Doe");
		assertThat(result).contains("firstName", "John");
	}

	@Test
	void addVisitThrowsForNullPetId() {
		Owner owner = new Owner();
		Visit visit = new Visit();
		assertThatThrownBy(() -> owner.addVisit(null, visit)).isInstanceOf(IllegalArgumentException.class);
	}

	@Test
	void addVisitThrowsForNullVisit() {
		Owner owner = new Owner();
		assertThatThrownBy(() -> owner.addVisit(1, null)).isInstanceOf(IllegalArgumentException.class);
	}

	@Test
	void addVisitThrowsForInvalidPetId() {
		Owner owner = new Owner();
		Visit visit = new Visit();
		assertThatThrownBy(() -> owner.addVisit(999, visit)).isInstanceOf(IllegalArgumentException.class);
	}

	@Test
	void addVisitSucceeds() {
		Owner owner = createOwnerWithPet("Fido", 1);
		Visit visit = new Visit();
		owner.addVisit(1, visit);
		assertThat(owner.getPet(1).getVisits()).contains(visit);
	}

}
