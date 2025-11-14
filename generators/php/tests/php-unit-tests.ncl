# PHP Unit Test Generator
# Generates PHPUnit tests

let config = import "../../../src/config.ncl" in

{
  test_code = m%"
<?php

namespace Circular\Protocol\Tests;

use Circular\Protocol\CircularProtocolAPI;
use Circular\Protocol\CircularProtocolException;
use PHPUnit\Framework\TestCase;

/**
 * Circular Protocol PHP SDK Unit Tests
 * Generated from Nickel API specification
 *
 * Tests SDK basic functionality and configuration
 */
class CircularProtocolUnitTest extends TestCase
{
    private CircularProtocolAPI $api;

    protected function setUp(): void
    {
        $this->api = new CircularProtocolAPI();
    }

    public function testConstructorSetsDefaultNagUrl(): void
    {
        $api = new CircularProtocolAPI();
        $this->assertEquals('https://nag.circularlabs.io/NAG.php?cep=', $api->getNagUrl());
    }

    public function testConstructorAcceptsCustomNagUrl(): void
    {
        $api = new CircularProtocolAPI('https://custom.url', null);
        $this->assertEquals('https://custom.url', $api->getNagUrl());
    }

    public function testConstructorAcceptsNagKey(): void
    {
        $api = new CircularProtocolAPI(null, 'test-key');
        $this->assertEquals('test-key', $api->getNagKey());
    }

    public function testSetNagUrlUpdatesUrl(): void
    {
        $this->api->setNagUrl('https://new.url');
        $this->assertEquals('https://new.url', $this->api->getNagUrl());
    }

    public function testSetNagKeyUpdatesKey(): void
    {
        $this->api->setNagKey('new-key');
        $this->assertEquals('new-key', $this->api->getNagKey());
    }

    public function testExceptionStoresStatusCode(): void
    {
        $exception = new CircularProtocolException('Test error', 404, '/test');

        $this->assertEquals(404, $exception->getStatusCode());
        $this->assertEquals('/test', $exception->getEndpoint());
        $this->assertEquals('Test error', $exception->getMessage());
    }
}
"%
}
