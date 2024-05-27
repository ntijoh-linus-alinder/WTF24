describe('landing page', () => {
  it('should open langingpage = passes', () => {
    cy.visit('http://localhost:9292')
  })
})

describe('login', () => {
  it('should login to page = passes', () => {
    cy.visit('http://localhost:9292')
    cy.contains('login')
    cy.get('a').contains('login').click();
    cy.get('input[name="username"]').type('linus')
    cy.get('input[name="password"]').type('test2')
    cy.get('form').submit() 

  })
})

describe('get access', () => {
  it('should visit editpage, dont have access, create account, login, and then have accses to /new = passes', () => {
    cy.visit('http://localhost:9292')
    cy.visit('http://localhost:9292/movies/new')
    cy.get('a').contains('register').click();
    cy.get('input[name="email"]').type('hej@gmail.com')
    cy.get('input[name="username"]').type('hej')
    cy.get('input[name="password"]').type('hej')
    cy.get('form').submit() 
    cy.get('input[name="username"]').type('hej')
    cy.get('input[name="password"]').type('hej')
    cy.get('form').submit()
    cy.visit('http://localhost:9292/movies/new')
})
})